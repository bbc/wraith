require "yaml"

class Snappy

  def initialize(config_name)
    @config = YAML::load_file(config_name + '.yaml')
  end

  def widths
    @config['screen_widths']
  end

  def base_domain
    hash = @config['domains']
    hash[hash.keys[0]]
  end

  def comp_domain
    hash = @config['domains']
    hash[hash.keys[1]]
  end

  def base_domain_label
    @config['domains'].keys[0]
  end

  def comp_domain_label
    @config['domains'].keys[1]
  end

  def paths
    @config['paths']
  end

  def capture_page_image (url, width, file_name)
    puts `phantomjs snap.js "#{url}" "#{width}" "#{file_name}"`
  end

  # Support for slimerjs, uncomment code below and comment out capture_page_image option above
  # def capture_page_image (url, width, file_name)
  #   puts `slimerjs snap.js "#{url}" "#{width}" "#{file_name}"`
  # end

  def compare_images (base, compare, output, info)
    puts `compare -fuzz 20% -metric AE -highlight-color blue #{base} #{compare} #{output} 2>#{info}`
  end

end

snappy = Snappy.new('config')

task :default => [:reset_shots_folder, :save_images, :compare_images, :create_gallery] do
  puts 'Done!';
end

task :compare_images do
  files = []
  Dir.glob("shots/*/*.png") do |filename|
    files << filename
  end

  while !files.empty?
    base, compare = files.slice!(0, 2)
    snappy.compare_images(base, compare, base.gsub(/([a-z]+).png$/, 'diff.png'), base.gsub(/([a-z]+).png$/, 'data.txt'))

    contents = ''
    Dir.glob('shots/*/*.txt').each do |f|
      contents += "\n#{f}\n"
      contents += File.read(f)
    end

    File.open("shots/data.txt", "w") {
      |file| file.write(contents)
    }
    puts 'Saved diff'
  end
end

task :reset_shots_folder do
    FileUtils.rm_rf('./shots')
    FileUtils.mkdir('shots')
end

task :save_images do

  base_domain = {'label' => snappy.base_domain_label, 'host' => snappy.base_domain}
  compare_domain = {'label' => snappy.comp_domain_label, 'host' => snappy.comp_domain}

  snappy.paths.each do |label, path|
    puts "processing '#{label}' '#{path}'"
    if !path
      path = label
      label = path.gsub('/','_')
    end

    FileUtils.mkdir("shots/#{label}")

    snappy.widths.each do |width|
      width = width.to_s
      compare_url = compare_domain['host'] + path
      base_url = base_domain['host'] + path

      compare_file_name = "shots/#{label}/#{width}_#{compare_domain['label']}.png"
      base_file_name = "shots/#{label}/#{width}_#{base_domain['label']}.png"

      snappy.capture_page_image compare_url, width, compare_file_name
      snappy.capture_page_image base_url, width, base_file_name
    end

  end
end

task :create_gallery do
  puts 'Creating html gallery...'
  ruby "create_gallery.rb shots/"
end
