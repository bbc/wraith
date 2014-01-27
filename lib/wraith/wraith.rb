require 'yaml'
require 'wraith/command_line_image_tool'

class Wraith::Wraith

  include CommandLineImageTool

  attr_accessor :config

  def initialize(config_name)
    @config = YAML::load(File.open("configs/#{config_name}.yaml"))
  end

  def directory
    @config['directory'].first
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

  def crop_images(crop, height)
    self.class.crop_images
  end


end
