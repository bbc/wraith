require "yaml"
require "wraith/helpers/utilities"

class Wraith::Wraith
  attr_accessor :config

  def initialize(config, yaml_passed = false)
    begin
      @config = yaml_passed ? config : open_config_file(config)
    rescue
      error "unable to find config at #{config}"
    end
    $wraith = self
  end

  def validate(mode = false)
    list_debug_information if verbose
    validate_basic_properties
    validate_mode_properties(mode) if mode
    # if we get this far, we've only had warnings at worst, not errors.
    puts "Config validated. No serious issues found."
  end

  def validate_basic_properties
    snap_file_from_engine engine # quick test to see if engine is recognised (even if manual snapfile is provided)
    if !domains
      error "You must specify at least one domain for Wraith to do anything! #{docs_prompt}"
    end
    #@TODO validate fuzz is not nil, etc
  end

  def validate_mode_properties(mode)
    case mode
    when "capture"
      validate_capture_mode
    when "history"
      validate_history_mode
    when "latest"
      validate_history_mode
      validate_base_shots_exist
    else
      warning "Wraith doesn't know how to validate mode '#{mode}'. Continuing..."
    end
  end

  def validate_capture_mode
    if domains.length != 2
      error "`wraith capture` requires exactly two domains. #{docs_prompt}"
    end
    if history_dir
      verbose_log "Warning: you have specified a `history_dir` in your config, but this is used in `history` mode, NOT `capture` mode. #{docs_prompt}"
    end
  end

  def validate_history_mode
    if !history_dir
      error "You must specify a `history_dir` to run Wraith in history mode. #{docs_prompt}"
    end
    if domains.length != 1
      error "History mode requires exactly one domain. #{docs_prompt}"
    end
  end

  def validate_base_shots_exist
    puts "@TODO - need to validate history mode base shots exist"
  end

  def docs_prompt
    "See the docs at http://bbc-news.github.io/wraith/"
  end

  def list_debug_information
    wraith_version      = Wraith::VERSION
    ruby_version        = run_command_safely('ruby -v') || 'Ruby not installed'
    phantomjs_version   = run_command_safely('phantomjs --version') || 'PhantomJS not installed'
    casperjs_version    = run_command_safely('casperjs --version') || 'CasperJS not installed'
    imagemagick_version = run_command_safely('convert -version') || 'ImageMagick not installed'

    puts "#################################################"
    puts "  Wraith version:     #{wraith_version}"
    puts "  Ruby version:       #{ruby_version}"
    puts "  ImageMagick:        #{imagemagick_version}"
    puts "  PhantomJS version:  #{phantomjs_version}"
    puts "  CasperJS version:   #{casperjs_version}"
    # @TODO - add a SlimerJS equivalent
    puts "#################################################"
    puts ""
  end

  def run_command_safely(command)
    begin
      output = `#{command}`
    rescue Exception => e
      return false
    end
    output.lines.first
  end

  def open_config_file(config_name)
    if File.exist?(config_name) && File.extname(config_name) == ".yaml"
      config = File.open config_name
    else
      config = File.open "configs/#{config_name}.yaml"
    end
    YAML.load config
  end

  def directory
    # Legacy support for those using array configs
    @config["directory"].is_a?(Array) ? @config["directory"].first : @config["directory"]
  end

  def history_dir
    @config["history_dir"] || false
  end

  def engine
    engine = @config["browser"]
    # Legacy support for those using the old style "browser: \n phantomjs: 'casperjs'" configs
    if engine.is_a? Hash
      engine = engine.values.first
    end
    engine
  end

  def snap_file
    @config["snap_file"] ? convert_to_absolute(@config["snap_file"]) : snap_file_from_engine(engine)
  end

  def snap_file_from_engine(engine)
    path_to_js_templates = File.dirname(__FILE__) + '/javascript'
    case engine
    when "phantomjs"
      path_to_js_templates + "/phantom.js"
    when "casperjs"
      path_to_js_templates + "/casper.js"
    # @TODO - add a SlimerJS option
    else
      error "Wraith does not recognise the browser engine '#{engine}'"
    end
  end

  def before_capture
    @config["before_capture"] ? convert_to_absolute(@config["before_capture"]) : "false"
  end

  def widths
    @config["screen_widths"]
  end

  def resize
    # @TODO make this default to true, once it's been tested a bit more thoroughly
    @config["resize_or_reload"] ? (@config["resize_or_reload"] == "resize") : false
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
    @config["phantomjs_options"] || '--ignore-ssl-errors=true --ssl-protocol=tlsv1'
  end

  def verbose
    # @TODO - also add a `--verbose` CLI flag which overrides whatever you have set in the config
    @config['verbose'] || false
  end

end
