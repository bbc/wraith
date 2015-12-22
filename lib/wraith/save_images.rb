require "parallel"
require "shellwords"
require "wraith"
require "wraith/helpers/capture_options"
require "wraith/helpers/save_metadata"

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
      # prepare for the command line. [30,40,50] => "30,40,50"
      width = width.join(',')
    end
    width
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
        command = construct_command(width, url, filename, selector, global_before_capture, path_before_capture)
        attempt_image_capture command
      rescue => e
        puts e
        create_invalid_image(filename, width)
      end
    end
  end

  def construct_command(width, url, file_name, selector, global_before_capture, path_before_capture)
    selector = selector.gsub '#', '\#' # make sure id selectors aren't escaped in the CLI
    capture_page_image = "#{meta.engine} #{wraith.phantomjs_options} '#{wraith.snap_file}' '#{url}' '#{width}' '#{file_name}' '#{selector}' '#{global_before_capture}' '#{path_before_capture}'"
    verbose_log capture_page_image
    return capture_page_image
  end

  def attempt_image_capture(capture_page_image, max_attempts = 5)
    max_attempts.times do |i|
      run_command capture_page_image

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
