require 'wraith'

class Wraith::FolderManager
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def dir
  	wraith.directory
  end

  def clear_shots_folder
    FileUtils.rm_rf("./#{dir}")
    FileUtils.mkdir("#{dir}")
  end

  def create_folders
    wraith.paths.each do |folder_label, path| 
      FileUtils.mkdir_p("#{dir}/thumbnails/#{folder_label}")
      FileUtils.mkdir("#{dir}/#{folder_label}")
    end
  end
end
