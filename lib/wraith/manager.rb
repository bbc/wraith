require 'wraith'
require 'image_size'
require 'anemone'
require 'uri'
require 'selenium-webdriver'

require 'wraith/wraith'

class WraithManager
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def directory
    wraith.directory
  end

  def compare_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort

    while !files.empty?
      base, compare = files.slice!(0, 2)
      diff = base.gsub(/([a-z0-9]+).png$/, 'diff.png')
      info = base.gsub(/([a-z0-9]+).png$/, 'data.txt')
      wraith.compare_images(base, compare, diff, info)
      contents = Dir.glob("#{wraith.directory}/*/*.txt").collect { |f| "\n#{f}\n#{File.read(f)}" }
      File.open("#{wraith.directory}/data.txt", 'w') { |file| file.write(contents.join) }
      puts 'Saved diff'
    end
  end

  def self.reset_shots_folder(dir)
    FileUtils.rm_rf("./#{dir}")
    FileUtils.mkdir("#{dir}")
  end

  def reset_shots_folder
    self.class.reset_shots_folder(wraith.directory)
  end

  def check_for_paths
    if !wraith.paths
      puts 'no paths defined'
      # check to see if there is an existing spider.txt file
      if File.exist?('spider.txt')
        # check that its within the use-by date set in the config
        if (Time.now - File.ctime('spider.txt')) / (24 * 3600) < wraith.spider_days[0]
          puts 'using existing spider file'
        else
          # if spider.txt files is out of date create a new one
          puts 'creating new spider file'
          spider_base_domain
        end
      else
        # create new spider.txt file
        puts 'creating new spider file'
        spider_base_domain
      end

    end
  end

  def spider_base_domain
    spider_list = []
    # set the crawl domain to the base domain in the confing
    crawl_url = wraith.base_domain
    # ignore urls to file extension such as images etc
    ext = %w(flv swf png jpg gif asx zip rar tar 7z gz jar js css dtd xsd ico raw mp3 mp4 wav wmv ape aac ac3 wma aiff mpg mpeg avi mov ogg mkv mka asx asf mp2 m1v m3u f4v pdf doc xls ppt pps bin exe rss xml)
    Anemone.crawl(crawl_url) do |anemone|
      anemone.skip_links_like /\.#{ext.join('|')}$/
      anemone.on_every_page do |page|
      # puts page.url
      # add the urls to the array
        spider_list << page.url.path
      end
    end

    $i = 0
    h = Hash.new { |h, k| h[k] = [] }
    # loop through the array and create the hash for the label => path pairs
    while $i < spider_list.length do
      lab = spider_list[$i].to_s.split('/').last
      if
        # correct label for home page
        spider_list[$i] == '/'
        lab = 'home'
      end
      h[lab] = spider_list[$i]

      $i += 1
    end
    # create the spider.txt file containing the hash
    File.open('spider.txt', 'w+') { |file| file.write(h) }
  end

  def save_images
    if !wraith.paths
      # if there are no path defined in the config use the spider.txt file
      p = File.read('spider.txt')
      p = eval(p)
    else
      # else use path from config
      p = wraith.paths
    end

    p.each do |label, path|
      puts "processing '#{label}' '#{path}'"

      if !path
        path = label
        label = path.gsub('/', '_')
      end

      FileUtils.mkdir("#{wraith.directory}/#{label}")
      FileUtils.mkdir_p("#{wraith.directory}/thumbnails/#{label}")

      compare_url = wraith.comp_domain + path if !wraith.comp_domain.nil?
      base_url = wraith.base_domain + path if !wraith.base_domain.nil?

      wraith.widths.each do |width|

        wraith.engine.each do |type, engine|
          # Used for headless browsers
          compare_file_name = "#{wraith.directory}/#{label}/#{width}_#{engine}_#{wraith.comp_domain_label.downcase}.png"
          base_file_name = "#{wraith.directory}/#{label}/#{width}_#{engine}_#{wraith.base_domain_label.downcase}.png"

          wraith.capture_page_image engine, compare_url, width, compare_file_name if !compare_url.nil?
          wraith.capture_page_image engine, base_url, width, base_file_name if !base_url.nil?

        end
      end
    end
  end

  def run_webdriver
    wraith.paths.each do |label, path|
      puts "processing '#{label}' '#{path}'"
      if !path
        path = label
        label = path.gsub('/', '_')
      end

      FileUtils.mkdir("#{wraith.directory}/#{label}")
      FileUtils.mkdir_p("#{wraith.directory}/thumbnails/#{label}")

      compare_url = wraith.comp_domain + path
      base_url = wraith.base_domain + path

      base_browser = wraith.browser1
      compare_browser = wraith.browser2

      wraith.widths.each do |width|

          # Used for devices/real browsers
        compare_file_name = "#{wraith.directory}/#{label}/#{width}_#{base_browser}_#{wraith.comp_domain_label}.png"
        base_file_name = "#{wraith.directory}/#{label}/#{width}_#{compare_browser}_#{wraith.base_domain_label}.png"

        wraith.web_runner base_browser, width, compare_url, compare_file_name
        wraith.web_runner compare_browser, width, base_url, base_file_name
      end
    end
  end

  def self.crop_images(dir)
    files = Dir.glob("#{dir}/*/*.png").sort

    while !files.empty?
      base, compare = files.slice!(0, 2)
      File.open(base, 'rb') do |fh|
        new_base_height = ImageSize.new(fh.read).size

        base_height = new_base_height[1]

        File.open(compare, 'rb') do |fh|
          new_compare_height = ImageSize.new(fh.read).size
          compare_height = new_compare_height[1]

          if base_height > compare_height
            height = base_height
            crop = compare
          else
            height = compare_height
            crop = base
          end

          puts 'cropping images'
          Wraith::Wraith.crop_images(crop, height)
        end
      end
    end
  end

  def crop_images
    self.class.crop_images(wraith.directory)
  end

  def generate_thumbnails
    Dir.glob("#{wraith.directory}/*/*.png").each do |filename|
      new_name = filename.gsub(/^#{wraith.directory}/, "#{wraith.directory}/thumbnails")
      wraith.thumbnail_image(filename, new_name)
    end
  end
end
