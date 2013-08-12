$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'snappy_manager'

snappy_manager = SnappyManager.new('config')

task :default => [:reset_shots_folder, :save_images, :crop_images, :compare_images, :generate_thumbnails, :generate_gallery] do
  puts 'Done!';
end

task :compare_images do
  snappy_manager.compare_images
end

task :reset_shots_folder do
  snappy_manager.reset_shots_folder
end

task :save_images do
  snappy_manager.save_images
end


task :crop_images do
  snappy_manager.crop_images
end

task :generate_thumbnails do
  snappy_manager.generate_thumbnails
end

task :generate_gallery do
  sh 'ruby create_gallery.rb shots'
end

