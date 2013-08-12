require 'rspec-given'
require 'snappy'
require 'snappy_manager'
# require 'image_size'

describe Snappy do
  Given(:config_name) { 'spec/test_config' }
  Given { SnappyManager.reset_shots_folder }
  Given(:test_url1) { "http://www.live.bbc.co.uk/news" }
  Given(:test_url2) { "http://www.live.bbc.co.uk/russian" }
  Given(:test_image1) { 'shots/test1.png' }
  Given(:test_image2) { 'shots/test2.png' }
  Given(:diff_image) { 'shots/test_diff.png' }
  Given(:data_txt) { 'shots/test.txt' }

  When(:snappy) { Snappy.new(config_name) }
  Then { snappy.is_a? Snappy }

  context "When creating a snappy worker" do
    When(:no_config) { Snappy.new }
    Then { no_config.should have_failed(ArgumentError) }

    Then { snappy.config.keys.size == 3 }
    Then { snappy.widths == [320, 600, 768, 1024, 1280] }
    Then { snappy.base_domain == "http://www.live.bbc.co.uk/news" }
    Then { snappy.comp_domain == "http://www.live.bbc.co.uk/russian" }
    Then { snappy.base_domain_label == "english" }
    Then { snappy.comp_domain_label == "russian" }
    Then { snappy.paths == { "home" => "/", "uk_index" => "/uk" } }
  end

  context "When capturing an image" do
    # capture_page_image
    When { snappy.capture_page_image( test_url1, 320, test_image1 ) }
    When(:image_size) { ImageSize.path(test_image1).size }
    Then { image_size[0] == 320 }
  end

  context "When comparing images" do
    When(:diff_image_size) do 
      snappy.capture_page_image( test_url1, 320, test_image1 )
      snappy.capture_page_image( test_url2, 320, test_image2 )
      snappy.compare_images( test_image1, test_image2, diff_image, data_txt )
      ImageSize.path(diff_image).size
    end
    Then { diff_image_size == 320 }
  end

  # crop_images
  # thumbnail_image
end
