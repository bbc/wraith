require "yaml"

class Wraith
  attr_accessor :config

  def initialize(config_name)
    @config = YAML::load(File.open("configs/#{config_name}.yaml"))
  end

  def directory
    @config['directory'].first
  end

  def snap_file
    @config['snap_file'] ? @config['snap_file'] : 'snap.js'
  end

  def widths
    @config['screen_widths']
  end

  def domains
    @config['domains']
  end

  def base_domain
    domains[base_domain_label]
  end

  def comp_domain
    domains[comp_domain_label]
  end

  def base_domain_label
    domains.keys[0]
  end

  def comp_domain_label
    domains.keys[1]
  end

  def paths
    @config['paths']
  end

  def capture_page_image (url, width, file_name)
    puts `phantomjs #{@config['phantomjs_options']} "#{snap_file}" "#{url}" "#{width}" "#{file_name}"`
  end

  # Support for slimerjs, uncomment code below and comment out capture_page_image option above
  # def capture_page_image (url, width, file_name)
  #   puts `slimerjs #{@config['phantomjs_options']} "#{snap_file}" "#{url}" "#{width}" "#{file_name}"`
  # end

  def compare_images (base, compare, output, info)
    puts `compare -fuzz 20% -metric AE -highlight-color blue #{base} #{compare} #{output} 2>#{info}`
  end

  def self.crop_images (crop, height)
    puts `convert #{crop} -background none -extent 0x#{height} #{crop}`
  end

  def crop_images(crop, height)
    self.class.crop_images
  end

  def thumbnail_image(png_path, output_path)
    `convert #{png_path} -thumbnail 200 -crop 200x200+0+0 #{output_path}`
  end
end
