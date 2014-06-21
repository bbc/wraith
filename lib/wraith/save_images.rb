require 'wraith'
require 'parallel'

class Wraith::SaveImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def directory
    wraith.directory
  end

  def check_paths
    if !wraith.paths
      path = File.read(wraith.spider_file)
      eval(path)
    else
      wraith.paths
    end
  end

  def engine
    wraith.engine.each { |_label, browser| return browser }
  end

  def base_urls(path)
    wraith.base_domain + path unless wraith.base_domain.nil?
  end

  def compare_urls(path)
    wraith.comp_domain + path unless wraith.comp_domain.nil?
  end

  def file_names(width, label, domain_label)
    "#{directory}/#{label}/#{width}_#{engine}_#{domain_label}.png"
  end

  def attempt_image_capture(width, url, filename, max_attempts)
    max_attempts.times do |i|
      wraith.capture_page_image engine, url, width, filename

      return if File.exist? filename

      puts "Failed to capture image #{filename} on attempt number #{i + 1} of #{max_attempts}"
    end

    fail "Unable to capture image #{filename} after #{max_attempts} attempt(s)"
  end

  def save_images
    jobs = []
    check_paths.each do |label, path|
      unless path
        path = label
        label = path.gsub('/', '_')
      end

      base_url = base_urls(path)
      compare_url = compare_urls(path)

      wraith.widths.each do |width|
        base_file_name    = file_names(width, label, wraith.base_domain_label)
        compare_file_name = file_names(width, label, wraith.comp_domain_label)

        jobs << [label, path, width, base_url,    base_file_name]
        jobs << [label, path, width, compare_url, compare_file_name]
      end
    end

    Parallel.each(jobs, in_threads: 8) do |_label, _path, width, url, filename|
      begin
        attempt_image_capture(width, url, filename, 5)
      rescue => e
        puts e

        puts 'Using fallback image instead'
        invalid = File.expand_path('../../assets/invalid.jpg', File.dirname(__FILE__))
        FileUtils.cp invalid, filename

        # Set width of fallback image
        wraith.set_image_width(filename, width)
      end
    end
  end
end
