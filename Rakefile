$:.unshift File.join(File.dirname(__FILE__), 'lib')

namespace :wraith do
  desc "Extracts config from file and generates Wraith output"
  task :process_run, :config_path do |t, args|

    unless args[:config_path]
      puts "Using default config path. "
      puts "Use 'rake wraith:process_run[path/to/config]' to use a different path to a config file"
    end
    
    require 'wraith_process'
    WraithProcess.run(args[:config_path])
    sh 'ruby create_gallery.rb shots'
  end

end

# Remove from future builds
task :default => ['wraith:process_run'] do
  puts 'Running Wraith via "rake" has been deprecated'
  puts 'Instead, please use "rake wraith:process_run"'
end
