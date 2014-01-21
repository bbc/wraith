require 'wraith'
require 'wraith/wraith'

class Wraith::SaveImages
  attr_reader :wraith
  attr_accessor :paths
  attr_accessor :labels
  attr_accessor :url_path

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
    @paths = paths
    @labels = labels
    @url_path = url_path
  end

  def directory
    wraith.directory
  end

  def setup_images
    if !wraith.paths
      url_path = File.read('spider.txt')
      url_path = eval(paths)
    else
      url_path = wraith.paths
    end
  end

  def define_paths
    setup_images.each do |label, path|
      unless path
        path = label
        label = path.gsub('/', '_')
      end

      @paths = path
      @labels = label
      puts "processing '#{labels}' '#{paths}'"

      FileUtils.mkdir_p("#{directory}/thumbnails/#{labels}")
      save_images
    end
  end

  def engine
    wraith.engine.each { |label, browser| return browser }
  end

  def compare_url
    wraith.comp_domain + "#{paths}" unless wraith.comp_domain.nil?
  end

  def base_url
    wraith.base_domain + "#{paths}" unless wraith.base_domain.nil?
  end

  def save_images
    wraith.widths.each do |widths|
      base_file_name = "#{directory}/#{labels}/#{widths}_#{engine}_#{wraith.base_domain_label}.png"
      compare_file_name = "#{directory}/#{labels}/#{widths}_#{engine}_#{wraith.comp_domain_label}.png"
    
      wraith.capture_page_image engine, base_url, widths, base_file_name unless base_url.nil?
      wraith.capture_page_image engine, compare_url, widths, compare_file_name unless compare_url.nil?
    end
  end

  def generate_thumbnails
    Dir.glob("#{directory}/*/*.png").each do |filename|
      new_name = filename.gsub(/^#{directory}/, "#{directory}/thumbnails")
      wraith.thumbnail_image(filename, new_name)
    end
  end
end
