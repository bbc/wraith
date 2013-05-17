
task :default => [:reset_shots_folder, :save_images, :compare_images] do
  puts 'Done!';
end

task :compare_images do
  files = []
  Dir.glob("shots/*/*.png") do |filename|
    files << filename
  end

  while !files.empty?
    base, compare = files.slice!(0, 2)
    Snappy.compare_images(base, compare, base.gsub(/([a-z]+).png$/, 'diff.png'))
    puts 'Saved diff'
  end

end

task :reset_shots_folder do
    FileUtils.rm_rf('./shots')
    FileUtils.mkdir('shots')
end

task :save_images do

  base_domain = {'label' => 'sandbox', 'host' => Snappy.domains['sandbox']}
  comapare_domain = {'label' => 'live', 'host' => Snappy.domains['live']}

  Snappy.paths.each do |label, path|

    FileUtils.mkdir("shots/#{label}")

    Snappy.widths.each do |width|
      width = width.to_s

      compare_url = comapare_domain['host'] + path
      base_url = base_domain['host'] + path

      compare_file_name = "shots/#{label}/#{width}_#{comapare_domain['label']}.png"
      base_file_name = "shots/#{label}/#{width}_#{base_domain['label']}.png"

      Snappy.capture_page_image compare_url, width, compare_file_name
      Snappy.capture_page_image base_url, width, base_file_name
    end

  end

end

module Snappy

  def self.domains
    {
      'live' => 'http://www.live.bbc.co.uk',
      'test' => 'http://pal.test.bbc.co.uk',
      'stage' => 'http://pal.stage.bbc.co.uk',
      'sandbox' => 'http://pal.sandbox.dev.bbc.co.uk',
      'int' => 'http://pal.int.bbc.co.uk',
      #'other' => 'http://'putsandboxnamehere'-sandbox.t.proxylocal.com',
    }
  end

  def self.paths
    {
      'front_page_news' => '/news',
      'story_page_news' => '/news/uk-politics-21271670',
      'live_page_news' => '/news/uk-politics-17456712',
      'story_page_news_hyper' => '/news/world-africa-21056884',
      'media_page_news' => '/news/uk-21163565',
      'media_page_news_index' => '/news/video_and_audio/uk/',
      'story_page_news_images' => '/news/uk-21112189',
      'gallery_page_news' => '/news/in-pictures-21828015',
      'local_page_news' => '/news/england/london',
      'local_weather' => '/news/northern_ireland/northern_ireland_politics'
      # 'special_reports' => '/news/uk-politics-22067257'



      # 'front_page_russia' => '/russian',
      # 'story_page_russia' => '/russian/international/2013/02/130217_nigeria_abductions',  
      # 'front_page_hausa' => '/hausa',
      # 'story_page_hausa' => '/hausa/news/2013/01/130131_syria_israel',
      # 'front_page_indonesia' => '/indonesia',
      # 'story_page_indonesia' => '/indonesia/dunia/2013/02/130206_jepancina',
     



    }
  end

  def self.widths
    [320, 599, 600, 768, 1024, 1280]
  end

  def self.capture_page_image (url, width, file_name)
    puts `phantomjs snap.js "#{url}" "#{width}" "#{file_name}"`
  end

  def self.compare_images (base, compare, output)
    puts `compare -fuzz 20% -highlight-color blue #{base} #{compare} #{output}`
  end

end
