$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'bundler/gem_tasks'
require 'wraith/save_images'
require 'wraith/crop'
require 'wraith/spider'
require 'wraith/folder'
require 'wraith/compare_images'

@save_images = Wraith::SaveImages.new('config')

task :config, [:args] do |t, args|
  args.with_defaults(:args => "config")
  @save_images = Wraith::SaveImages.new("#{args[:args]}")
  Rake::Task["default"].invoke
end

task :default => [:reset_shots_folder, :check_for_paths, :setup_images, :define_paths, :file_name, :save_images, :crop_images, :compare_images, :generate_thumbnails, :generate_gallery] do
  puts 'Done!';
end

task :reset_shots_folder do
  reset = Wraith::ClearShots.new('config')
  reset.clear_shots_folder
end

task :compare_images do
  compare = Wraith::CompareImages.new('config')
  compare.compare_images
end

task :check_for_paths do
  spider = Wraith::Spidering.new('config')
  spider.check_for_paths
end

task :setup_images do
  @save_images.setup_images
end

task :save_images do
  @save_images.save_images
end

task :define_paths do
  @save_images.define_paths
end

task :file_name do
  @save_images.file_name
end

task :crop_images do
  crop = Wraith::CropImages.new('config')
  crop.crop_images
end

task :generate_thumbnails do
  @save_images.generate_thumbnails
end

task :generate_gallery do
  sh "ruby lib/wraith/gallery.rb #{@save_images.directory}"
end

task :grabber, [:args] do |t, args|
  args.with_defaults(:args => "config")
  @save_images = WraithManager.new("#{args[:args]}")
  Rake::Task["grab"].invoke
end

task :grab => [:reset_shots_folder, :check_for_paths, :save_images, :generate_thumbnails, :generate_gallery] do
  puts 'Done!';
end
