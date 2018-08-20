require "wraith"
require "fileutils"

class SaveMetadata
  attr_reader :wraith, :history

  def initialize(config, history)
    @wraith = config
    @history = history
  end

  def history_label
    history ? "_latest" : ""
  end

  def file_names(width, label, domain_label)
    width = "MULTI" if width.is_a? Array

    FileUtils::mkdir_p "#{wraith.directory}/#{label}"   # ensure the directory exists
    "#{wraith.directory}/#{label}/#{width}_#{engine}_#{domain_label}.png"
  end

  def base_label
    "#{wraith.base_domain_label}#{history_label}"
  end

  def compare_label
    "#{wraith.comp_domain_label}#{history_label}"
  end

  def engine
    wraith.engine
  end
end
