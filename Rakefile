task :config, [:yaml] do |t, custom|
  custom.with_defaults(:yaml => "config")
  @config = "#{custom[:yaml]}"
  Rake::Task["default"].invoke
end

task :grabber, [:yaml] do |t, custom|
  custom.with_defaults(:yaml => "config")
  @config = "#{custom[:yaml]}"
  Rake::Task["grab"].invoke
end

task :grab => [:reset_shots_folder, :check_for_paths, :setup_folders, :save_images, :generate_thumbnails, :generate_gallery] do
  puts 'Done!';
end
