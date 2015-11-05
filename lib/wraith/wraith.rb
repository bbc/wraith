require "yaml"

class Wraith::Wraith
  attr_accessor :config

  def initialize(config_name)
    if File.exist?(config_name) && File.extname(config_name) == ".yaml"
      @config = YAML.load(File.open(config_name))
    else
      @config = YAML.load(File.open("configs/#{config_name}.yaml"))
    end
  rescue
    puts "unable to find config at #{config_name}"
    exit 1
  end

  def directory
    # Legacy support for those using array configs
    @config["directory"].is_a?(Array) ? @config["directory"].first : @config["directory"]
  end

  def history_dir
    @config["history_dir"]
  end

  def snap_file
    @config["snap_file"] ? @config["snap_file"] : File.expand_path("lib/wraith/javascript/snap.js")
  end

  def before_capture
    @config["before_capture"] || "false"
  end

  def widths
    @config["screen_widths"]
  end

  def domains
    @config["domains"]
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
    @config["spider_file"] ? @config["spider_file"] : "spider.txt"
  end

  def spider_days
    @config["spider_days"]
  end

  def sitemap
    @config["sitemap"]
  end

  def spider_skips
    @config["spider_skips"]
  end

  def paths
    @config["paths"]
  end

  def engine
    @config["browser"]
  end

  def fuzz
    @config["fuzz"]
  end

  def highlight_color
    @config["highlight_color"] ? @config["highlight_color"] : "blue"
  end

  def mode
    if %w(diffs_only diffs_first alphanumeric).include?(@config["mode"])
      @config["mode"]
    else
      "alphanumeric"
    end
  end

  def threshold
    @config["threshold"] ? @config["threshold"] : 0
  end

  def gallery_template
    default = 'basic_template'
    if @config["gallery"].nil?
      default
    else
      @config["gallery"]["template"] || default
    end
  end

  def thumb_height
    default = 200
    if @config["gallery"].nil?
      default
    else
      @config["gallery"]["thumb_height"] || default
    end
  end

  def thumb_width
    default = 200
    if @config["gallery"].nil?
      default
    else
      @config["gallery"]["thumb_width"] || default
    end
  end

  def phantomjs_options
    @config["phantomjs_options"]
  end
end
