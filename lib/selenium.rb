require 'wraith'
require 'image_size'
require 'anemone'
require 'uri'
require 'selenium-webdriver'

class Browsers
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith.new(config)
  end

  def directory
    wraith.directory
  end	

  def webdriver

    if !wraith.paths
      #if there are no path defined in the config use the spider.txt file
      p = File.read("spider.txt")
      p = eval(p)
    else
      #else use path from config
      p = wraith.paths
    end

    p.each do |label, path|
      puts "processing '#{label}' '#{path}'"
      
      if !path
        path = label
        label = path.gsub('/','_')
      end

      FileUtils.mkdir("#{wraith.directory}/#{label}")
      FileUtils.mkdir_p("#{wraith.directory}/thumbnails/#{label}")

      compare_url = wraith.comp_domain + path
      base_url = wraith.base_domain + path

      base_browser = wraith.browser1
      compare_browser = wraith.browser2
      

      wraith.widths.each do |width|
          
          compare_file_name = "#{wraith.directory}/#{label}/#{width}_#{base_browser}_#{wraith.comp_domain_label}.png"
          base_file_name = "#{wraith.directory}/#{label}/#{width}_#{compare_browser}_#{wraith.base_domain_label}.png"

          wraith.web_awesome base_browser, compare_url, compare_file_name
          wraith.web_awesome compare_browser, base_url, base_file_name
      
      end
    end
  end

  def self.crop_images(dir)
    files = Dir.glob("#{dir}/*/*.png").sort

    while !files.empty?
      base, compare = files.slice!(0, 2)
      File.open(base, "rb") do |fh|
        new_base_height = ImageSize.new(fh.read).size

        base_height = new_base_height[1]

        File.open(compare, "rb") do |fh|
          new_compare_height = ImageSize.new(fh.read).size
          compare_height = new_compare_height[1]

          if base_height > compare_height
            height = base_height
            crop = compare
          else
            height = compare_height
            crop = base
          end

          puts "cropping images"
          Wraith.crop_images(crop, height)
        end
      end
    end
  end

  def crop_images
    self.class.crop_images(wraith.directory)
  end

end
