require 'thor'
require 'thor/group'
require 'wraith'
require 'wraith/save_images'
require 'wraith/crop'
require 'wraith/spider'
require 'wraith/folder'
require 'wraith/thumbnails'
require 'wraith/compare_images'
require 'wraith/images'

class Wraith::CLI < Thor::Group
  include Thor::Actions

  def setup
    @config = ('config')
  end

  desc "reset shots"
  def reset_shots
    reset = Wraith::FolderManager.new(@config)
    reset.clear_shots_folder
  end

  desc "setup folders"
  def setup_folders
    create = Wraith::FolderManager.new(@config)
    create.create_folders
  end

  desc "check paths"
  def check_for_paths
    spider = Wraith::Spidering.new(@config)
    spider.check_for_paths
  end

  desc "save images"
  def save_images
    save_images = Wraith::SaveImages.new(@config)
    save_images.save_images
  end

  desc "check images"
  def check_images
    image = Wraith::Images.new(@config)
    image.files
  end

  desc "crop images"
  def crop_images
    crop = Wraith::CropImages.new(@config)
    crop.crop_images
  end

  desc "compare images"
  def compare_images
    compare = Wraith::CompareImages.new(@config)
    compare.compare_images
  end

  def generate_thumbnails
    thumbs = Wraith::Thumbnails.new(@config)
    thumbs.generate_thumbnails
  end

  def generate_gallery
    dir = Wraith::Wraith.new(@config)
    puts 'Generating gallery'
    `ruby lib/wraith/gallery.rb "#{dir.directory}"`
  end
end
