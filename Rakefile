$:.unshift File.join(File.dirname(__FILE__), 'lib')

namespace :wraith do
  desc "Extracts config from file and generates Wraith output"
  task :process_run do
    require 'wraith_process'
    WraithProcess.run
    sh 'ruby create_gallery.rb shots'
  end

end

# Remove from future builds
task :default => ['wraith:process_run'] do
  puts 'Running Wraith via "rake" has been deprecated'
  puts 'Instead, please use "rake wraith:process_run"'
end
