require "wraith"
require "wraith/helpers/logger"
require "yaml"
require "anemone"
require "uri"

class Wraith::Spider
  include Logging

  EXT = %w(flv swf png jpg gif asx zip rar tar 7z \
           gz jar js css dtd xsd ico raw mp3 mp4 m4a \
           wav wmv ape aac ac3 wma aiff mpg mpeg \
           avi mov ogg mkv mka asx asf mp2 m1v \
           m3u f4v pdf doc xls ppt pps bin exe rss xml)

  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config, { imports_must_resolve: false })
    @paths = {}
  end

  def crawl
    logger.info "Crawling #{wraith.base_domain}"
    Anemone.crawl(wraith.base_domain) do |anemone|
      anemone.skip_links_like(/\.(#{EXT.join('|')})$/)
      # Add user specified skips
      anemone.skip_links_like(wraith.spider_skips)
      anemone.on_every_page do |page|
        logger.info "    #{page.url.path}"
        add_path(page.url.path)
      end
    end

    logger.info "Crawl complete."
    write_file
  end

  def add_path(path)
    @paths[path == "/" ? "home" : path.gsub("/", "__").chomp("__").downcase] = path.downcase
  end

  def write_file
    logger.info "Writing to YML file..."
    config = {}
    config['paths'] = @paths
    File.open("#{wraith.config_dir}/#{wraith.imports}", "w+") do |file|
      file.write(config.to_yaml)
      logger.info "Spider paths written to #{wraith.imports}"
    end
  end
end
