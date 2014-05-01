require 'wraith'

class Wraith::SaveImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def directory
    wraith.directory
  end

  def check_paths
    if !wraith.paths
      path = File.read(wraith.spider_file)
      eval(path)
    else
      wraith.paths
    end
  end

  def engine
    wraith.engine.each { |label, browser| return browser }
  end

  def compare_engine
    if !wraith.compare_engine
      return nil
    else
      wraith.compare_engine.each { |label, browser| return browser }
    end
  end

  def base_urls(path)
    wraith.base_domain + path unless wraith.base_domain.nil?
  end

  def compare_urls(path)
    wraith.comp_domain + path unless wraith.comp_domain.nil?
  end

  def file_names(width, label, domain_label, engine)
    "#{directory}/#{label}/#{width}_#{engine}_#{domain_label}.png"
  end

  def save_images
    check_paths.each do |label, path|
      if !path
        path = label 
        label = path.gsub('/', '_') 
      end

      base_url = base_urls(path)
      compare_url = compare_urls(path)

      wraith.widths.each do |width|
        base_file_name = file_names(width, label, wraith.base_domain_label, engine)
        wraith.capture_page_image engine, base_url, width, base_file_name, wraith.snap_file unless base_url.nil?

        if compare_engine.nil? && !compare_url.nil?
          compare_file_name = file_names(width, label, wraith.comp_domain_label, engine)
          wraith.capture_page_image engine, compare_url, width, compare_file_name, wraith.snap_file unless compare_url.nil?
        else
          compare_file_name = file_names(width, label, wraith.base_domain_label, compare_engine)
          wraith.capture_page_image compare_engine, base_url, width, compare_file_name, wraith.compare_snap_file
        end
      end
    end
  end
end
