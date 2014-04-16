require 'yaml'

class Wraith::Config
  attr_accessor :config

  def initialize(config_name)
    if File.exists? config_name
      @config = YAML::load(File.open(config_name))
      @snap_path = File.expand_path(File.dirname("#{config_name}"))
    else
      @config = YAML::load(File.open("configs/#{config_name}.yaml"))
      @snap_path = File.dirname(__FILE__)
    end
  end

  def directory
    @config['directory'].first
  end

  def snap_file
    file = @config['snap_file'] ? @config['snap_file'] : 'javascript/snap.js'
    File.expand_path(file, @snap_path)
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

  def phantom_ops
    @config['phantomjs_options']
  end
end
