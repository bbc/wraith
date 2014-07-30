require 'yaml'

class Wraith::Wraith
  attr_accessor :config

  def initialize(config_name)
    if File.exist?(config_name) && File.extname(config_name) == '.yaml'
      @config = YAML.load(File.open(config_name))
    else
      @config = YAML.load(File.open("configs/#{config_name}.yaml"))
    end
  rescue
    puts 'unable to find config'
    exit 1
  end

  def directory
    @config['directory'].first
  end

  def snap_file
    @config['snap_file'] ? @config['snap_file'] : File.expand_path('lib/wraith/javascript/snap.js')
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

  def sitemap
    @config['sitemap']
  end

  def spider_skips
    @config['spider_skips']
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

  def mode
    if %w(diffs_only diffs_first alphanumeric).include?(@config['mode'])
      @config['mode']
    else
      'alphanumeric'
    end
  end

  def phantomjs_options
    @config['phantomjs_options']
  end
end
