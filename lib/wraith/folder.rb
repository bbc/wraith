require "wraith"
require "wraith/helpers/logger"

class Wraith::FolderManager
  include Logging
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
      logger.debug "Read the spider file...."
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
      logger.error "no `history_dir` attribute found in config. Cannot copy files."
    else
      FileUtils.cp_r("#{dir}/.", "#{history_dir}/")
      FileUtils.rm_rf("#{history_dir}/thumbnails") # thumbnails aren't generated until the gallery stage anyway
      FileUtils.rm_rf("#{dir}") # get rid of the live folder
      Dir["#{history_dir}/**/*.png"].each do |filepath|
        new_name = filepath.gsub("latest.png", "base.png")
        File.rename(filepath, new_name)
      end
    end
  end

  def copy_base_images
    logger.info "COPYING BASE IMAGES"
    spider_paths.each do |path|
      path = path[0]
      logger.info "Copying #{history_dir}/#{path} to #{dir}"
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
    logger.info "Creating Folders"
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
          return false unless v.include?(:diff)
          return false if v[:data] > wraith.threshold
        rescue
          return true
        end
      end
    end
  end
end
