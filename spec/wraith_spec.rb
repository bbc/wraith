require 'rspec-given'
require 'wraith'
require 'wraith_manager'

describe Wraith do
  Given(:config_name) { 'test_config' }
  Given { WraithManager.reset_shots_folder }
  Given(:test_url1) { "http://www.live.bbc.co.uk/news" }
  Given(:test_url2) { "http://www.live.bbc.co.uk/russian" }
  Given { Dir.mkdir('shots/test') } 
  Given(:test_image1) { 'shots/test/test1.png' }
  Given(:test_image2) { 'shots/test/test2.png' }
  Given(:diff_image) { 'shots/test/test_diff.png' }
  Given(:data_txt) { 'shots/test/test.txt' }

  When(:wraith) { Wraith.new(config_name) }
  Then { wraith.is_a? Wraith }

  context "When creating a wraith worker" do
    When(:no_config) { Wraith.new }
    Then { no_config.should have_failed(ArgumentError) }

    Then { wraith.config.keys.size == 3 }
    Then { wraith.widths == [320, 600, 768, 1024, 1280] }
    Then { wraith.base_domain == "http://www.live.bbc.co.uk/news" }
    Then { wraith.comp_domain == "http://www.live.bbc.co.uk/russian" }
    Then { wraith.base_domain_label == "english" }
    Then { wraith.comp_domain_label == "russian" }
    Then { wraith.paths == { "home" => "/", "uk_index" => "/uk" } }
  end

  context "When capturing an image" do
    # capture_page_image
    When { wraith.capture_page_image( test_url1, 320, test_image1 ) }
    When(:image_size) { ImageSize.path(test_image1).size }
    Then { image_size[0] == 320 }
  end

  context "When comparing images" do
    When(:diff_image_size) do 
      wraith.capture_page_image( test_url1, 320, test_image1 )
      wraith.capture_page_image( test_url2, 320, test_image2 )
      WraithManager.crop_images 
      wraith.compare_images( test_image1, test_image2, diff_image, data_txt )
      ImageSize.path(diff_image).size
    end
    Then { diff_image_size[0] == 320 }
  end

  # crop_images
  # thumbnail_image
end
