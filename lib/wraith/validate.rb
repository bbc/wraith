require "wraith/wraith"
require "wraith/helpers/logger"
require "wraith/helpers/utilities"

class Wraith::Validate
  include Logging
  attr_reader :wraith

  def initialize(config, options = {})
    @wraith = Wraith::Wraith.new(config, options)
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
    when "spider"
      validate_spider_mode
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

  def validate_spider_mode
    fail MissingRequiredPropertyError, "You must specify an `imports` YML"\
                  " before running `wraith spider`. #{docs_prompt}" unless wraith.imports

    #fail PropertyOutOfContextError, "Tried running `wraith spider` but you have already"\
    #                              " specified paths in your YML. #{docs_prompt}" if wraith.paths
  end

  def validate_base_shots_exist
    unless File.directory?(wraith.history_dir)
      logger.error "You need to run `wraith history` at least once before you can run `wraith latest`!"
    end
  end

  def docs_prompt
    "See the docs at http://bbc-news.github.io/wraith/"
  end
end
