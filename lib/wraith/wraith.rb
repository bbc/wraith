require "yaml"
require "wraith/helpers/logger"
require "wraith/helpers/utilities"

class Wraith::Wraith
  include Logging
  attr_accessor :config

  def initialize(config, options = {})
    options = {
      yaml_passed: false,
      imports_must_resolve: true,
    }.merge(options)

    if options[:yaml_passed]
      @config = config
    else
      filepath = determine_config_path config
      @config = YAML.load_file filepath
      if !@config
        fail InvalidYamlError, "could not parse \"#{config}\" as YAML"
      end
    end

    if @config['imports']
      @config = apply_imported_config(@config['imports'], @config, options[:imports_must_resolve])
    end

    logger.level = verbose ? Logger::DEBUG : Logger::INFO
  end

  def determine_config_path(config_name)
    possible_filenames = [
      config_name,
      "#{config_name}.yml",
      "#{config_name}.yaml",
      "configs/#{config_name}.yml",
      "configs/#{config_name}.yaml"
    ]

    possible_filenames.each do |filepath|
      if File.exist?(filepath)
        @calculated_config_dir = absolute_path_of_dir(convert_to_absolute filepath)
        return convert_to_absolute filepath
      end
    end

    fail ConfigFileDoesNotExistError, "unable to find config \"#{config_name}\""
  end

  def config_dir
    @calculated_config_dir
  end

  def apply_imported_config(config_to_import, config, imports_must_resolve)
    path_to_config = "#{config_dir}/#{config_to_import}"
    if File.exist?(path_to_config)
      yaml = YAML.load_file path_to_config
      return yaml.merge(config)
    end

    if imports_must_resolve
      fail ConfigFileDoesNotExistError, "unable to find referenced imported config \"#{config_to_import}\""
    else
      config # return original config
    end
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
    engine = engine.values.first if engine.is_a? Hash
    engine
  end

  def snap_file
    @config["snap_file"] ? convert_to_absolute(@config["snap_file"]) : snap_file_from_engine(engine)
  end

  def snap_file_from_engine(engine)
    path_to_js_templates = File.dirname(__FILE__) + "/javascript"
    case engine
    when "phantomjs"
      path_to_js_templates + "/phantom.js"
    when "casperjs"
      path_to_js_templates + "/casper.js"
    # @TODO - add a SlimerJS option
    else
      logger.error "Wraith does not recognise the browser engine '#{engine}'"
    end
  end

  def before_capture
    @config["before_capture"] ? convert_to_absolute(@config["before_capture"]) : false
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
    default = "basic_template"
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

  def imports
    @config['imports'] || false
  end

  def verbose
    # @TODO - also add a `--verbose` CLI flag which overrides whatever you have set in the config
    @config["verbose"] || false
  end
  
  def platform
    @config['platform'] || 'desktop'
  end
end
