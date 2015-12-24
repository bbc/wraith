require "wraith/wraith"
require "wraith/helpers/utilities"

class Wraith::Validate
  def initialize(config, yaml_passed = false)
    @wraith = Wraith::Wraith.new(config, yaml_passed)
  end

  def validate(mode = false)
    list_debug_information if @wraith.verbose
    validate_basic_properties
    validate_mode_properties(mode) if mode
    # if we get this far, we've only had warnings at worst, not errors.
    "Config validated. No serious issues found."
  end

  def validate_basic_properties
    if @wraith.engine.nil?
      raise MissingRequiredPropertyError, "You must specify a browser engine! #{docs_prompt}"
    end
    unless @wraith.domains
      raise MissingRequiredPropertyError, "You must specify at least one domain for Wraith to do anything! #{docs_prompt}"
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
    if @wraith.domains.length != 2
      raise InvalidDomainsError, "`wraith capture` requires exactly two domains. #{docs_prompt}"
    end
    if @wraith.history_dir
      verbose_log "Warning: you have specified a `history_dir` in your config, but this is used in `history` mode, NOT `capture` mode. #{docs_prompt}"
    end
  end

  def validate_history_mode
    unless @wraith.history_dir
      raise MissingRequiredPropertyError, "You must specify a `history_dir` to run Wraith in history mode. #{docs_prompt}"
    end
    if @wraith.domains.length != 1
      raise InvalidDomainsError, "History mode requires exactly one domain. #{docs_prompt}"
    end
  end

  def validate_base_shots_exist
    # @TODO - need to validate history mode base shots exist
  end

  def docs_prompt
    "See the docs at http://bbc-news.github.io/wraith/"
  end

  def list_debug_information
    wraith_version      = Wraith::VERSION
    ruby_version        = run_command_safely('ruby -v')             || 'Ruby not installed'
    phantomjs_version   = run_command_safely('phantomjs --version') || 'PhantomJS not installed'
    casperjs_version    = run_command_safely('casperjs --version')  || 'CasperJS not installed'
    imagemagick_version = run_command_safely('convert -version')    || 'ImageMagick not installed'

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
end