require "yaml"

module Snappy
  def self.config=(config)
    @config = config
  end
 
  def self.widths
    resolutions = @config['screen_widths']
  end

  def self.capture_page_image (url, width, file_name)
    puts `phantomjs snap.js "#{url}" "#{width}" "#{file_name}"`
  end

  def self.compare_images (base, compare, output)
    puts `compare -fuzz 20% -highlight-color blue #{base} #{compare} #{output}`
  end
end

config = YAML::load_file('config.yaml')

Snappy.config = config


task :default => [:reset_shots_folder, :save_images, :compare_images] do
  puts 'Done!';
end

task :compare_images do
  files = []
  Dir.glob("shots/*/*.png") do |filename|
    files << filename
  end

  while !files.empty?
    base, compare = files.slice!(0, 2)
    Snappy.compare_images(base, compare, base.gsub(/([a-z]+).png$/, 'diff.png'))
    puts 'Saved diff'
  end

end

task :reset_shots_folder do
    FileUtils.rm_rf('./shots')
    FileUtils.mkdir('shots')
end

task :save_images do
  
  base_domain = {'label' => config["base_domain_label"], 'host' => config['base_domain']}
  compare_domain = {'label' => config["comp_domain_label"], 'host' => config['compare_domain']}

  path_list = config['paths']
  path_list.each do |label, path|

    FileUtils.mkdir("shots/#{label}")
    
    Snappy.widths.each do |width|
      width = width.to_s

      compare_url = compare_domain['host'] + path
      base_url = base_domain['host'] + path

      compare_file_name = "shots/#{label}/#{width}_#{compare_domain['label']}.png"
      base_file_name = "shots/#{label}/#{width}_#{base_domain['label']}.png"

      Snappy.capture_page_image compare_url, width, compare_file_name
      Snappy.capture_page_image base_url, width, base_file_name
    end

  end

end
