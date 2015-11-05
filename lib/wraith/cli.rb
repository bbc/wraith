require "thor"
require "wraith"
require "wraith/save_images"
require "wraith/crop"
require "wraith/spider"
require "wraith/folder"
require "wraith/thumbnails"
require "wraith/compare_images"
require "wraith/gallery"

class Wraith::CLI < Thor
  include Thor::Actions

  attr_accessor :config_name

  def self.source_root
    File.expand_path("../../../", __FILE__)
  end

  desc "setup", "creates config folder and default config"
  def setup
    directory("templates/configs", "configs")
    directory("templates/javascript", "javascript")
  end

  desc "reset_shots [config_name]", "removes all the files in the shots folder"
  def reset_shots(config_name)
    reset = Wraith::FolderManager.new(config_name)
    reset.clear_shots_folder
  end

  desc "setup_folders [config_name]", "create folders for images"
  def setup_folders(config_name)
    create = Wraith::FolderManager.new(config_name)
    create.create_folders
  end

  desc "copy_base_images [config_name]", "copies the required base images over for comparison with latest images"
  def copy_base_images(config_name)
    copy = Wraith::FolderManager.new(config_name)
    copy.copy_base_images
  end

  desc "make_sure_base_shots_exists [config_name]", "warns user if config is missing base shots"
  def make_sure_base_shots_exists(config_name)
    wraith = Wraith::Wraith.new(config_name)
    if wraith.history_dir.nil?
      puts "You need to specify a `history_dir` property at #{config_name} before you can run `wraith latest`!"
      exit 1
    end
    if !File.directory?(wraith.history_dir)
      puts "You need to run `wraith history` at least once before you can run `wraith latest`!"
      exit 1
    end
  end

  no_commands do
    def check_for_paths(config_name)
      spider = Wraith::Spidering.new(config_name)
      spider.check_for_paths
    end

    def copy_old_shots(config_name)
      create = Wraith::FolderManager.new(config_name)
      create.copy_old_shots
    end
  end

  desc "save_images [config_name]", "captures screenshots"
  def save_images(config_name, history = false)
    puts "SAVING IMAGES"
    save_images = Wraith::SaveImages.new(config_name, history)
    save_images.save_images
  end

  desc "crop_images [config_name]", "crops images to the same height"
  def crop_images(config_name)
    crop = Wraith::CropImages.new(config_name)
    crop.crop_images
  end

  desc "compare_images [config_name]", "compares images to generate diffs"
  def compare_images(config_name)
    puts "COMPARING IMAGES"
    compare = Wraith::CompareImages.new(config_name)
    compare.compare_images
  end

  desc "generate_thumbnails [config_name]", "create thumbnails for gallery"
  def generate_thumbnails(config_name)
    puts "GENERATING THUMBNAILS"
    thumbs = Wraith::Thumbnails.new(config_name)
    thumbs.generate_thumbnails
  end

  desc "generate_gallery [config_name]", "create page for viewing images"
  def generate_gallery(config_name, multi = false)
    puts "GENERATING GALLERY"
    gallery = Wraith::GalleryGenerator.new(config_name, multi)
    gallery.generate_gallery
  end

  desc "capture [config_name]", "A full Wraith job"
  def capture(config, multi = false)
    reset_shots(config)
    check_for_paths(config)
    setup_folders(config)
    save_images(config)
    crop_images(config)
    compare_images(config)
    generate_thumbnails(config)
    generate_gallery(config, multi)
  end

  desc "multi_capture [filelist]", "A Batch of Wraith Jobs"
  def multi_capture(filelist)
    config_array = IO.readlines(filelist)
    config_array.each do |config|
      capture(config.chomp, true)
    end
  end

  desc "history [config_name]", "Setup a baseline set of shots"
  def history(config)
    reset_shots(config)
    check_for_paths(config)
    setup_folders(config)
    save_images(config)
    copy_old_shots(config)
  end

  desc "latest [config_name]", "Capture new shots to compare with baseline"
  def latest(config)
    make_sure_base_shots_exists(config)
    reset_shots(config)
    save_images(config, true)
    copy_base_images(config)
    crop_images(config)
    compare_images(config)
    generate_thumbnails(config)
    generate_gallery(config)
  end
end
