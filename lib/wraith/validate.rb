require "wraith/wraith"
require "wraith/helpers/logger"
require "wraith/helpers/utilities"

class Wraith::Validate
  include Logging
  attr_reader :wraith

  def initialize(config, yaml_passed = false)
    @wraith = Wraith::Wraith.new(config, yaml_passed)
  end

  def validate(mode = false)
    list_debug_information if wraith.verbose
    validate_basic_properties
    validate_mode_properties(mode) if mode
    # if we get this far, we've only had warnings at worst, not errors.
    "Config validated. No serious issues found."
  end

  def validate_basic_properties
    fail MissingRequiredPropertyError, "You must specify a browser engine! #{docs_prompt}" if wraith.engine.nil?

    fail MissingRequiredPropertyError, "You must specify at least one domain for Wraith to do anything! #{docs_prompt}" unless wraith.domains

    fail MissingRequiredPropertyError, "You must specify a directory for capture! #{docs_prompt}" if wraith.directory.nil?

    # @TODO validate fuzz is not nil, etc
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
      logger.warn "Wraith doesn't know how to validate mode '#{mode}'. Continuing..."
    end
  end

  def validate_capture_mode
    fail InvalidDomainsError, "`wraith capture` requires exactly two domains. #{docs_prompt}" if wraith.domains.length != 2

    logger.warn "You have specified a `history_dir` in your config, but this is"\
                " used in `history` mode, NOT `capture` mode. #{docs_prompt}" if wraith.history_dir
  end

  def validate_history_mode
    fail MissingRequiredPropertyError, "You must specify a `history_dir` to run"\
                  " Wraith in history mode. #{docs_prompt}" unless wraith.history_dir

    fail InvalidDomainsError, "History mode requires exactly one domain. #{docs_prompt}" if wraith.domains.length != 1
  end

  def validate_base_shots_exist
    unless File.directory?(wraith.history_dir)
      logger.error "You need to run `wraith history` at least once before you can run `wraith latest`!"
    end
  end

  def docs_prompt
    "See the docs at http://bbc-news.github.io/wraith/"
  end

  def list_debug_information
    wraith_version      = Wraith::VERSION
    command_run         = ARGV.join ' '
    ruby_version        = run_command_safely("ruby -v") || "Ruby not installed"
    phantomjs_version   = run_command_safely("phantomjs --version") || "PhantomJS not installed"
    casperjs_version    = run_command_safely("casperjs --version") || "CasperJS not installed"
    imagemagick_version = run_command_safely("convert -version") || "ImageMagick not installed"

    logger.debug "#################################################"
    logger.debug "  Command run:        #{command_run}"
    logger.debug "  Wraith version:     #{wraith_version}"
    logger.debug "  Ruby version:       #{ruby_version}"
    logger.debug "  ImageMagick:        #{imagemagick_version}"
    logger.debug "  PhantomJS version:  #{phantomjs_version}"
    logger.debug "  CasperJS version:   #{casperjs_version}"
    # @TODO - add a SlimerJS equivalent
    logger.debug "#################################################"
    logger.debug ""
  end

  def run_command_safely(command)
    begin
      output = `#{command}`
    rescue StandardError
      return false
    end
    output.lines.first
  end
end
