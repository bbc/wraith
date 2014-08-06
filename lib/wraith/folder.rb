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
    FileUtils.mkdir_p("#{dir}")
  end

  def create_folders
    spider_paths.each do |folder_label, path|
      unless path
        path = folder_label
        folder_label = path.gsub('/', '__')
      end

      FileUtils.mkdir_p("#{dir}/thumbnails/#{folder_label}")
      FileUtils.mkdir_p("#{dir}/#{folder_label}")
    end
    puts 'Creating Folders'
  end

  # Tidy up the shots folder, removing uncessary files
  #
  def tidy_shots_folder(dirs)
    if wraith.mode == 'diffs_only'
      dirs.each do |a, b|
        # If we are running in "diffs_only mode, and none of the variants show a difference
        # we remove the file from the shots folder
        if b.none? { |_k, v| v[:data] > 0 }
          FileUtils.rm_rf("#{wraith.directory}/#{a}")
          dirs.delete(a)
        end
      end
    end
  end
end
