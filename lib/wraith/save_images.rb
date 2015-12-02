require "wraith"
require "parallel"
require "shellwords"
require "wraith/utilities"

class Wraith::SaveImages
  attr_reader :wraith, :history, :meta

  def initialize(config, history = false, yaml_passed = false)
    @wraith = Wraith::Wraith.new(config, yaml_passed)
    @history = history
    @meta = SaveMetadata.new(@wraith, history)
  end

  def check_paths
    if !wraith.paths
      path = File.read(wraith.spider_file)
      eval(path)
    else
      wraith.paths
    end
  end

  def save_images
    jobs = define_jobs
    parallel_task(jobs)
  end

  def define_jobs
    jobs = []
    check_paths.each do |label, options|
      settings = CaptureOptions.new(options, wraith)

      if settings.resize
        jobs = jobs + define_individual_job(label, settings, wraith.widths)
      else
        wraith.widths.each do |width|
          jobs = jobs + define_individual_job(label, settings, width)
        end
      end
    end
    jobs
  end

  def define_individual_job(label, settings, width)
    base_file_name    = meta.file_names(width, label, meta.base_label)
    compare_file_name = meta.file_names(width, label, meta.compare_label)

    jobs = []
    jobs << [label, settings.path, prepare_widths_for_cli(width), settings.base_url,    base_file_name,    settings.selector, wraith.before_capture, settings.before_capture]
    jobs << [label, settings.path, prepare_widths_for_cli(width), settings.compare_url, compare_file_name, settings.selector, wraith.before_capture, settings.before_capture] unless settings.compare_url.nil?

    jobs
  end

  def prepare_widths_for_cli(width)
    if width.kind_of? Array
      # prepare for the command line. [30,40,50] => "'30','40','50'"
      width = width.map{ |i| "'#{i}'" }.join(',')
    end
    width
  end

  def capture_page_image(browser, url, width, file_name, selector, global_before_capture, path_before_capture)

    command = "#{browser} #{wraith.phantomjs_options} '#{wraith.snap_file}' '#{url}' \"#{width}\" '#{file_name}' '#{selector}' '#{global_before_capture}' '#{path_before_capture}'"

    # @TODO - uncomment the following line when we add a verbose mode
    # puts command
    run_command command
  end

  def run_command(command)
    output = []
    IO.popen(command).each do |line|
      puts line
      output << line.chomp!
    end.close
    output
  end

  def parallel_task(jobs)
    Parallel.each(jobs, :in_threads => 8) do |_label, _path, width, url, filename, selector, global_before_capture, path_before_capture|
      begin
        attempt_image_capture(width, url, filename, selector, global_before_capture, path_before_capture, 5)
      rescue => e
        puts e
        create_invalid_image(filename, width)
      end
    end
  end

  def attempt_image_capture(width, url, filename, selector, global_before_capture, path_before_capture, max_attempts)
    max_attempts.times do |i|
      capture_page_image meta.engine, url, width, filename, selector, global_before_capture, path_before_capture

      if wraith.resize
        return # @TODO - need to check if the image was generated, as per the reload example below
      end

      return if File.exist? filename

      puts "Failed to capture image #{filename} on attempt number #{i + 1} of #{max_attempts}"
    end

    fail "Unable to capture image #{filename} after #{max_attempts} attempt(s)"
  end

  def create_invalid_image(filename, width)
    puts "Using fallback image instead"
    invalid = File.expand_path("../../assets/invalid.jpg", File.dirname(__FILE__))
    FileUtils.cp invalid, filename

    set_image_width(filename, width)
  end

  def set_image_width(image, width)
    `convert #{image.shellescape} -background none -extent #{width}x0 #{image.shellescape}`
  end
end

class CaptureOptions
  attr_reader :options, :wraith

  def initialize(options, wraith)
    @options = options
    @wraith = wraith
  end

  def path
    has_casper(options)
  end

  def selector
    options["selector"] || "body"
  end

  def resize
    # path level, or YAML-file level `resize_or_reload` property value
    if @options["resize_or_reload"]
      (@options["resize_or_reload"] == 'resize')
    else
      @wraith.resize
    end
  end

  def before_capture
    @options["before_capture"] ? convert_to_absolute(@options["before_capture"]) : "false"
  end

  def base_url
    base_urls(path)
  end

  def compare_url
    compare_urls(path)
  end

  def base_urls(path)
    wraith.base_domain + path unless wraith.base_domain.nil?
  end

  def compare_urls(path)
    wraith.comp_domain + path unless wraith.comp_domain.nil?
  end

  def has_casper(options)
    options["path"] ? options["path"] : options
  end
end

class SaveMetadata
  attr_reader :wraith, :history

  def initialize(config, history)
    @wraith = config
    @history = history
  end

  def history_label
    history ? "_latest" : ""
  end

  def file_names(width, label, domain_label)
    if width.kind_of? Array
      width = 'MULTI'
    end
    "#{wraith.directory}/#{label}/#{width}_#{engine}_#{domain_label}.png"
  end

  def base_label
    "#{wraith.base_domain_label}#{history_label}"
  end

  def compare_label
    "#{wraith.comp_domain_label}#{history_label}"
  end

  def engine
    wraith.engine
  end
end
