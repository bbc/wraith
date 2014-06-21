require 'thor'
require 'wraith'
require 'wraith/save_images'
require 'wraith/crop'
require 'wraith/spider'
require 'wraith/folder'
require 'wraith/thumbnails'
require 'wraith/compare_images'
require 'wraith/images'
require 'wraith/gallery'

class Wraith::CLI < Thor
  include Thor::Actions

  attr_accessor :config_name

  def self.source_root
    File.expand_path('../../../templates/', __FILE__)
  end

  desc 'setup', 'creates config folder and default config'
  def setup
    template('configs/config.yaml', 'configs/config.yaml')
    template('javascript/snap.js', 'javascript/snap.js')
  end

  desc 'reset_shots [config_name]', 'removes all the files in the shots folder'
  def reset_shots(config_name)
    reset = Wraith::FolderManager.new(config_name)
    reset.clear_shots_folder
  end

  desc 'setup_folders [config_name]', 'create folders for images'
  def setup_folders(config_name)
    create = Wraith::FolderManager.new(config_name)
    create.create_folders
  end

  no_commands do
    def check_for_paths(config_name)
      spider = Wraith::Spidering.new(config_name)
      spider.check_for_paths
    end

    def check_images(config_name)
      image = Wraith::Images.new(config_name)
      image.files
    end
  end

  desc 'save_images [config_name]', 'captures screenshots'
  def save_images(config_name)
    save_images = Wraith::SaveImages.new(config_name)
    save_images.save_images
  end

  desc 'crop_images [config_name]', 'crops images to the same height'
  def crop_images(config_name)
    crop = Wraith::CropImages.new(config_name)
    crop.crop_images
  end

  desc 'compare_images [config_name]', 'compares images to generate diffs'
  def compare_images(config_name)
    compare = Wraith::CompareImages.new(config_name)
    compare.compare_images
  end

  desc 'generate_thumbnails [config_name]', 'create thumbnails for gallery'
  def generate_thumbnails(config_name)
    thumbs = Wraith::Thumbnails.new(config_name)
    thumbs.generate_thumbnails
  end

  desc 'generate_gallery [config_name]', 'create page for viewing images'
  def generate_gallery(config_name)
    gallery = Wraith::GalleryGenerator.new(config_name)
    gallery.generate_gallery
    puts 'Gallery generated'
  end

  desc 'capture [config_name]', 'A full Wraith job'
  def capture(config)
    reset_shots(config)
    check_for_paths(config)
    setup_folders(config)
    save_images(config)
    check_images(config)
    crop_images(config)
    compare_images(config)
    generate_thumbnails(config)
    generate_gallery(config)
  end
end
