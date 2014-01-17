$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'bundler/gem_tasks'
require 'wraith/manager'
require 'wraith/crop'
require 'wraith/spider'

@wraith_manager = WraithManager.new('config')

task :config, [:args] do |t, args|
  args.with_defaults(:args => "config")
  @wraith_manager = WraithManager.new("#{args[:args]}")
  Rake::Task["default"].invoke
end

task :default => [:reset_shots_folder, :check_for_paths, :save_images, :crop_images, :compare_images, :generate_thumbnails, :generate_gallery] do
  puts 'Done!';
end

task :compare_images do
  @wraith_manager.compare_images
end

task :reset_shots_folder do
  @wraith_manager.reset_shots_folder
end

task :check_for_paths do
  spider = Wraith::Spidering.new('config')
  spider.check_for_paths
end

task :save_images do
  @wraith_manager.save_images
end

task :crop_images do
  crop = Wraith::CropImages.new('config')
  crop.crop_images
end

task :generate_thumbnails do
  @wraith_manager.generate_thumbnails
end

task :generate_gallery do
  sh "ruby lib/wraith/gallery.rb #{@wraith_manager.directory}"
end

task :grabber, [:args] do |t, args|
  args.with_defaults(:args => "config")
  @wraith_manager = WraithManager.new("#{args[:args]}")
  Rake::Task["grab"].invoke
end

task :grab => [:reset_shots_folder, :check_for_paths, :save_images, :generate_thumbnails, :generate_gallery] do
  puts 'Done!';
end
