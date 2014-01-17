require 'wraith'
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
          compare_file_name = "#{wraith.directory}/#{label}/#{width}_#{engine}_#{wraith.comp_domain_label}.png"
          base_file_name = "#{wraith.directory}/#{label}/#{width}_#{engine}_#{wraith.base_domain_label}.png"

          wraith.capture_page_image engine, compare_url, width, compare_file_name if !compare_url.nil?
          wraith.capture_page_image engine, base_url, width, base_file_name if !base_url.nil?

        end
      end
    end
  end

  def generate_thumbnails
    Dir.glob("#{wraith.directory}/*/*.png").each do |filename|
      new_name = filename.gsub(/^#{wraith.directory}/, "#{wraith.directory}/thumbnails")
      wraith.thumbnail_image(filename, new_name)
    end
  end
end
