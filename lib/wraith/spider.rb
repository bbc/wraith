require 'wraith'
require 'anemone'
require 'uri'

class Wraith::Spidering
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def check_for_paths
    unless wraith.paths
      puts 'no paths defined'
      spider
    end
  end

  def spider
    if File.exist?(wraith.spider_file)
      check_file
    else
      puts 'creating new spider file'
      spider_base_domain
    end
  end

  def check_file
    if (Time.now - File.ctime(wraith.spider_file)) / (24 * 3600) < wraith.spider_days[0]
      puts 'using existing spider file'
    else
      puts 'creating new spider file'
      spider_base_domain
    end
  end

  def spider_base_domain
    spider_list = []
    crawl_url = wraith.base_domain
    ext = %w(flv swf png jpg gif asx zip rar tar 7z \
             gz jar js css dtd xsd ico raw mp3 mp4 \
             wav wmv ape aac ac3 wma aiff mpg mpeg \
             avi mov ogg mkv mka asx asf mp2 m1v \
             m3u f4v pdf doc xls ppt pps bin exe rss xml)

    Anemone.crawl(crawl_url) do |anemone|
      anemone.skip_links_like(/\.#{ext.join('|')}$/)
      anemone.on_every_page { |page| spider_list << page.url.path }
    end
    create_spider_file(spider_list)
  end

  def create_spider_file(spider_list)
    spider = Hash[ spider_list.map{ |v| [ v == '/' ? 'home' : v.tr('/', '_').chomp('_').downcase, v.downcase] } ]
    File.open(wraith.spider_file, 'w+') { |file| file.write(spider) }
  end
end
