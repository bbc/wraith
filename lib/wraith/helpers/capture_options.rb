require "wraith"
require "wraith/helpers/utilities"

class CaptureOptions
  attr_reader :options, :wraith

  def initialize(options, wraith)
    @options = options
    @wraith = wraith
  end

  def path
    casper?(options)
  end

  def base_path
    options.is_a?(Hash) && options.key?('base_path') ? options['base_path'] : path
  end

  def compare_path
    options.is_a?(Hash) && options.key?('compare_path') ? options['compare_path'] : path
  end

  def selector
    options["selector"] || "body"
  end

  def resize
    # path level, or YAML-file level `resize_or_reload` property value
    if options["resize_or_reload"]
      (options["resize_or_reload"] == "resize")
    else
      wraith.resize
    end
  end

  def before_capture
    options["before_capture"] ? convert_to_absolute(options["before_capture"]) : false
  end

  def base_url
    base_urls(base_path)
  end

  def compare_url
    compare_urls(compare_path)
  end

  def base_urls(path)
    wraith.base_domain + path unless wraith.base_domain.nil?
  end

  def compare_urls(path)
    wraith.comp_domain + path unless wraith.comp_domain.nil?
  end

  def casper?(options)
    options["path"] ? options["path"] : options
  end
end
