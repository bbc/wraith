  task :compare do

  FileUtils.rm_rf('./shots')
  FileUtils.mkdir('shots')

  domains = {
    'live' => 'http://www.live.bbc.co.uk',
    'stage' => 'http://pal.stage.bbc.co.uk',
    'sandbox' => 'http://pal.sandbox.dev.bbc.co.uk'
  }

  base_domain = {'label' => 'live', 'host' => domains['live']}
  comapare_domain = {'label' => 'stage', 'host' => domains['stage']}

  paths = {
    'front_page_news' => '/news',
    'front_page_hausa' => '/hausa'
  }

  widths = [320, 600]
  paths.each do |label, path|

    FileUtils.mkdir("shots/#{label}")

    widths.each do |width|
      width = width.to_s

      puts `phantomjs snap.js "#{comapare_domain['host']}#{path}" "shots/#{label}/_#{width}_#{comapare_domain['label']}.png"`
      puts `phantomjs snap.js "#{base_domain['host']}#{path}" "shots/#{label}/#{width}_#{base_domain['label']}.png"`
    end

  end

    # puts `phantomjs snap.js "http://pal.stage.bbc.co.uk/indonesia" "2.png"`
    # puts 'Processing diff'
    # puts `composite 1.png 2.png -compose difference diff.png`

  end
