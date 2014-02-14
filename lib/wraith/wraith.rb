require 'yaml'

class Wraith::Wraith

  attr_accessor :config

  def initialize(config_name)
    @logger = Wraith::Logger.new
    @config = YAML::load(File.open("configs/#{config_name}.yaml"))
    @image_tool = Wraith::CommandLineImageTool.new(phantomjs_options, snap_file, fuzz)
  end

  def logger
    @logger
  end

  def directory
    @config['directory'].first
  end

  def phantomjs_options
    @config['phantomjs_options']
  end

  def snap_file
    @config['snap_file'] ? @config['snap_file'] : File.expand_path('javascript/snap.js', File.dirname(__FILE__))
  end

  def widths
    @config['screen_widths']
  end

  def domains
    @config['domains']
  end

  def base_domain
    domains[base_domain_label]
  end

  def comp_domain
    domains[comp_domain_label]
  end

  def base_domain_label
    domains.keys[0]
  end

  def comp_domain_label
    domains.keys[1]
  end
  
  def spider_file
    @config['spider_file'] ? @config['spider_file'] : 'spider.txt'
  end

  def spider_days
    @config['spider_days']
  end

  def paths
    @config['paths']
  end

  def engine
    @config['browser']
  end

  def fuzz
    @config['fuzz']
  end

  def capture_page_image(browser, url, width, file_name)
    @image_tool.capture_page_image(browser, url, width, file_name)
  end

  def compare_images(base, compare, output, info)
    @image_tool.compare_images(base, compare, output, info)
  end

  def crop_images(crop, height)
    @image_tool.crop_images(crop, height)
  end

  def thumbnail_image(png_path, output_path)
    @image_tool.thumbnail_image(png_path, output_path)
  end


end
