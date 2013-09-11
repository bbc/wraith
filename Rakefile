$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'wraith_manager'

@wraith_manager = WraithManager.new('config')

task :config, [:args] do |t, args|
  args.with_defaults(:args => "config")
  @wraith_manager = WraithManager.new("#{args[:args]}")
  Rake::Task["default"].invoke
end

task :default => [:config, :reset_shots_folder, :save_images, :crop_images, :compare_images, :generate_thumbnails, :generate_gallery] do
  puts 'Done!';
end

task :compare_images do
  @wraith_manager.compare_images
end

task :reset_shots_folder do
  @wraith_manager.reset_shots_folder
end

task :save_images do
  @wraith_manager.save_images
end

task :crop_images do
  @wraith_manager.crop_images
end

task :generate_thumbnails do
  @wraith_manager.generate_thumbnails
end

task :generate_gallery do
  sh "ruby create_gallery.rb #{@wraith_manager.directory}"
end
