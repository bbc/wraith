require "parallel"
require "shellwords"
require "wraith"
require "wraith/helpers/capture_options"
require "wraith/helpers/logger"
require "wraith/helpers/save_metadata"
require "wraith/helpers/utilities"
require "selenium-webdriver"
require 'mini_magick'

class Wraith::SaveImages
  include Logging
  attr_reader :wraith, :history, :meta

  def initialize(config, history = false, yaml_passed = false)
    @wraith = Wraith::Wraith.new(config, { yaml_passed: yaml_passed })
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
        jobs += define_individual_job(label, settings, wraith.widths)
      else
        wraith.widths.each do |width|
          jobs += define_individual_job(label, settings, width)
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
    # prepare for the command line. [30,40,50] => "30,40,50"
    width = width.join(",") if width.is_a? Array
    width
  end

  def run_command(command)
    output = []
    IO.popen(command).each do |line|
      logger.info line
      output << line.chomp!
    end.close
    output
  end

  def parallel_task(jobs)
    Parallel.each(jobs, :in_threads => 8) do |_label, _path, width, url, filename, selector, global_before_capture, path_before_capture|
      begin
        if meta.engine == "chrome"
          capture_image_selenium(width, url, filename, selector, global_before_capture, path_before_capture)
        else
          command = construct_command(width, url, filename, selector, global_before_capture, path_before_capture)
          attempt_image_capture(command, filename)
        end
      rescue => e
        logger.error e
        create_invalid_image(filename, width)
      end
    end
  end

  # currently only chrome headless at 1x scaling
  def get_driver
    case meta.engine
    when "chrome"
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--disable-gpu')
      options.add_argument('--headless')
      options.add_argument('--device-scale-factor=1') # have to change cropping for 2x. also this is faster
      options.add_argument('--force-device-scale-factor')
      options.add_argument("--window-size=1200,1500") # resize later so we can reuse drivers
      options.add_argument("--hide-scrollbars") # hide scrollbars from screenshots
      Selenium::WebDriver.for :chrome, options: options
    end
  end

  # resize to fit entire page
  def resize_to_fit_page driver
    width  = driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
    height = driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
    driver.manage.window.resize_to(width, height)
  end 

  # crop an image around the coordinates of an element
  def crop_selector driver, selector, image_location
    el = driver.find_element(:css, selector)
    image = MiniMagick::Image.open(image_location)
    image.crop "#{el.rect.width}x#{el.rect.height}+#{el.rect.x}+#{el.rect.y}"
    image.write(image_location)
  end

  def capture_image_selenium(screen_sizes, url, file_name, selector, global_before_capture, path_before_capture)
    driver = get_driver
    screen_sizes.to_s.split(",").each do |screen_size|
      width, height = screen_size.split("x")
      new_file_name = file_name.sub('MULTI', screen_size)
      driver.manage.window.resize_to(width, height || 1500)
      driver.navigate.to url
      driver.execute_async_script(File.read(global_before_capture)) if global_before_capture
      driver.execute_async_script(File.read(path_before_capture)) if path_before_capture
      resize_to_fit_page(driver) unless height
      driver.save_screenshot(new_file_name)
      crop_selector(driver, selector, new_file_name) if selector && selector.length > 0
    end
    driver.quit
  end

  def construct_command(width, url, file_name, selector, global_before_capture, path_before_capture)
    width    = prepare_widths_for_cli(width)
    selector = selector.gsub '#', '\#' # make sure id selectors aren't escaped in the CLI
    global_before_capture = convert_to_absolute global_before_capture
    path_before_capture   = convert_to_absolute path_before_capture

    command_to_run = "#{meta.engine} #{wraith.phantomjs_options} '#{wraith.snap_file}' '#{url}' '#{width}' '#{file_name}' '#{selector}' '#{global_before_capture}' '#{path_before_capture}' '#{wraith.platform}'"
    logger.debug command_to_run
    command_to_run
  end

  def attempt_image_capture(capture_page_image, filename)
    max_attempts = 5
    max_attempts.times do |i|
      run_command capture_page_image
      return true if image_was_created filename
      logger.warn "Failed to capture image #{filename} on attempt number #{i + 1} of #{max_attempts}"
    end

    fail "Unable to capture image #{filename} after #{max_attempts} attempt(s)" unless image_was_created filename
  end

  def image_was_created(filename)
     # @TODO - need to check if the image was generated even if in resize mode
    wraith.resize or File.exist? filename
  end

  def create_invalid_image(filename, width)
    logger.warn "Using fallback image instead"
    invalid = File.expand_path("../../assets/invalid.jpg", File.dirname(__FILE__))
    FileUtils.cp invalid, filename

    set_image_width(filename, width)
  end

  def set_image_width(image, width)
    `convert #{image.shellescape} -background none -extent #{width}x0 #{image.shellescape}`
  end
end
