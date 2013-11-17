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

          wraith.web_awesome base_browser, width, compare_url, compare_file_name
          wraith.web_awesome compare_browser, width, base_url, base_file_name
      
      end
    end
  end
end
