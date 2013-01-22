  task :compare do

    puts `phantomjs snap.js "http://www.live.bbc.co.uk/indonesia" "1.png"`
    puts `phantomjs snap.js "http://pal.stage.bbc.co.uk/indonesia" "2.png"`
    puts 'Processing diff'
    puts `composite 1.png 2.png -compose difference diff.png`

  end
