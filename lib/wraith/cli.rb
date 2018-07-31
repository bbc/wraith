require "thor"
require "wraith"
require "wraith/save_images"
require "wraith/crop"
require "wraith/spider"
require "wraith/folder"
require "wraith/thumbnails"
require "wraith/compare_images"
require "wraith/gallery"
require "wraith/validate"
require "wraith/version"
require "wraith/helpers/logger"
require "wraith/helpers/utilities"

class Wraith::CLI < Thor
  include Thor::Actions
  include Logging

  attr_accessor :config_name

  def self.source_root
    File.expand_path("../../../", __FILE__)
  end

  desc "validate [config_name]", "checks your configuration and validates that all required properties exist"
  def validate(config_name)
    within_acceptable_limits do
      logger.info Wraith::Validate.new(config_name).validate
    end
  end

  desc "setup", "creates config folder and default config"
  def setup
    within_acceptable_limits do
      directory("templates/configs", "configs")
      directory("templates/javascript", "javascript")
    end
  end

  desc "spider [config_name]", "crawls a site for paths and stores them to YML file"
  def spider(config)
    within_acceptable_limits do
      logger.info Wraith::Validate.new(config, { imports_must_resolve: false }).validate("spider")
      spider = Wraith::Spider.new(config)
      spider.crawl
    end
  end

  desc "reset_shots [config_name]", "removes all the files in the shots folder"
  def reset_shots(config_name)
    within_acceptable_limits do
      reset = Wraith::FolderManager.new(config_name)
      reset.clear_shots_folder
    end
  end

  desc "setup_folders [config_name]", "create folders for images"
  def setup_folders(config_name)
    within_acceptable_limits do
      create = Wraith::FolderManager.new(config_name)
      create.create_folders
    end
  end

  desc "copy_base_images [config_name]", "copies the required base images over for comparison with latest images"
  def copy_base_images(config_name)
    within_acceptable_limits do
      copy = Wraith::FolderManager.new(config_name)
      copy.copy_base_images
    end
  end

  desc "save_images [config_name]", "captures screenshots"
  def save_images(config_name, history = false)
    within_acceptable_limits do
      logger.info "SAVING IMAGES"
      save_images = Wraith::SaveImages.new(config_name, history)
      save_images.save_images
    end
  end

  desc "crop_images [config_name]", "crops images to the same height"
  def crop_images(config_name)
    within_acceptable_limits do
      logger.info "CROPPING IMAGES"
      crop = Wraith::CropImages.new(config_name)
      crop.crop_images
    end
  end

  desc "compare_images [config_name]", "compares images to generate diffs"
  def compare_images(config_name)
    within_acceptable_limits do
      logger.info "COMPARING IMAGES"
      compare = Wraith::CompareImages.new(config_name)
      compare.compare_images
    end
  end

  desc "generate_thumbnails [config_name]", "create thumbnails for gallery"
  def generate_thumbnails(config_name)
    within_acceptable_limits do
      logger.info "GENERATING THUMBNAILS"
      thumbs = Wraith::Thumbnails.new(config_name)
      thumbs.generate_thumbnails
    end
  end

  desc "generate_gallery [config_name]", "create page for viewing images"
  def generate_gallery(config_name, multi = false)
    within_acceptable_limits do
      logger.info "GENERATING GALLERY"
      gallery = Wraith::GalleryGenerator.new(config_name, multi)
      gallery.generate_gallery
    end
  end

  desc "capture [config_name]", "Capture paths against two domains, compare them, generate gallery"
  def capture(config, multi = false)
    within_acceptable_limits do
      logger.info Wraith::Validate.new(config).validate("capture")
      reset_shots(config)
      setup_folders(config)
      save_images(config)
      crop_images(config)
      compare_images(config)
      generate_thumbnails(config)
      generate_gallery(config, multi)
    end
  end

  desc "multi_capture [filelist]", "A Batch of Wraith Jobs"
  def multi_capture(filelist)
    within_acceptable_limits do
      config_array = IO.readlines(filelist)
      config_array.each do |config|
        capture(config.chomp, true)
      end
    end
  end

  desc "history [config_name]", "Setup a baseline set of shots"
  def history(config)
    within_acceptable_limits do
      logger.info Wraith::Validate.new(config).validate("history")
      reset_shots(config)
      setup_folders(config)
      save_images(config)
      Wraith::FolderManager.new(config).copy_old_shots
    end
  end

  desc "latest [config_name]", "Capture new shots to compare with baseline"
  def latest(config)
    within_acceptable_limits do
      logger.info Wraith::Validate.new(config).validate("latest")
      reset_shots(config)
      setup_folders(config)
      save_images(config, true)
      copy_base_images(config)
      crop_images(config)
      compare_images(config)
      generate_thumbnails(config)
      generate_gallery(config)
    end
  end

  desc "info", "Show various info about your system"
  def info
    list_debug_information
  end

  desc "version", "Show the version of Wraith"
  map ["--version", "-version", "-v"] => "version"
  def version
    logger.info Wraith::VERSION
  end
end
