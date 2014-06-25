require 'wraith'

class Wraith::FolderManager
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def dir
    wraith.directory
  end

  def paths
    wraith.paths
  end

  def spider_paths
    if !paths
      paths = File.read(wraith.spider_file)
      eval(paths)
    else
      wraith.paths
    end
  end

  def clear_shots_folder
    FileUtils.rm_rf("./#{dir}")
    FileUtils.mkdir("#{dir}")
  end

  def create_folders
    spider_paths.each do |folder_label, path|
      unless path
        path = folder_label
        folder_label = path.gsub('/', '_')
      end

      FileUtils.mkdir_p("#{dir}/thumbnails/#{folder_label}")
      FileUtils.mkdir("#{dir}/#{folder_label}")
    end
    puts 'Creating Folders'
  end
end
