require "wraith"

class Wraith::FolderManager
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def dir
    wraith.directory
  end

  def history_dir
    wraith.history_dir
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

  def copy_old_shots
    if history_dir.nil?
      abort 'Error: no `history_dir` attribute found in config. Cannot copy files.'
    else
      FileUtils.cp_r("#{dir}/.", "#{history_dir}/")
    end
  end

  def copy_base_images
    puts "COPYING BASE IMAGES"
    wraith.paths.each do |path|
      path = path[0]
      puts "Copying #{history_dir}/#{path} to #{dir}"
      FileUtils.cp_r(Dir.glob("#{history_dir}/#{path}"), dir)
    end
  end

  def create_folders
    spider_paths.each do |folder_label, path|
      unless path
        path = folder_label
        folder_label = path.gsub("/", "__")
      end

      FileUtils.mkdir_p("#{dir}/thumbnails/#{folder_label}")
      FileUtils.mkdir_p("#{dir}/#{folder_label}")
    end
    puts "Creating Folders"
  end

  def tidy_shots_folder(dirs)
    if wraith.mode == "diffs_only"
      dirs.each do |folder_name, shot_info|
        if shot_info.none? { |_k, v| v[:data] > 0 }
          FileUtils.rm_rf("#{wraith.directory}/#{folder_name}")
          dirs.delete(folder_name)
        end
      end
    end
  end

  def threshold_rate(dirs)
    dirs.each do |_folder_name, shot_info|
      shot_info.each do |_k, v|
        begin
          if !v.include?(:diff)
            return false
          elsif v[:data] > wraith.threshold
            return false
          end
        rescue
          return true
        end
      end
    end
  end
end
