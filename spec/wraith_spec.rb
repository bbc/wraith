require 'rspec-given'
require 'image_size'
require './lib/wraith/cli'

describe Wraith do
  Given(:config_name) { 'test_config' }
  Given { Wraith::FolderManager.new(config_name).clear_shots_folder }
  Given(:test_url1) { 'http://www.live.bbc.co.uk/news' }
  Given(:test_url2) { 'http://www.live.bbc.co.uk/russian' }
  Given { Dir.mkdir('shots/test') }
  Given(:test_image1) { 'shots/test/test1.png' }
  Given(:test_image2) { 'shots/test/test2.png' }
  Given(:diff_image) { 'shots/test/test_diff.png' }
  Given(:data_txt) { 'shots/test/test.txt' }

  When(:wraith) { Wraith::Wraith.new(config_name) }
  Then { wraith.is_a? Wraith::Wraith }

  context 'When creating a wraith worker' do

    Then { wraith.config.keys.size == 8 }
    Then { wraith.widths == [320, 600, 768, 1024, 1280] }
    Then { wraith.base_domain == 'http://pal.live.bbc.com/news' }
    Then { wraith.comp_domain == 'http://pal.live.bbc.co.uk/russian' }
    Then { wraith.base_domain_label == 'english' }
    Then { wraith.comp_domain_label == 'russian' }
    Then { wraith.paths == { 'home' => '/', 'uk_index' => '/uk' } }
  end

  context 'When capturing an image' do
    # capture_page_image
    When do
      wraith.engine.each do |_type, engine|
        wraith.capture_page_image(engine, test_url1, 320, test_image1)
      end
    end
    When(:image_size) { ImageSize.path(test_image1).size }
    Then { image_size[0] == 320 }
  end

  context 'When comparing images' do
    When(:diff_image_size) do
      wraith.engine.each do |_type, engine|
        wraith.capture_page_image(engine, test_url1, 320, test_image1)
        wraith.capture_page_image(engine, test_url2, 320, test_image2)
      end
      Wraith::CropImages.new(config_name).crop_images
      Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
      ImageSize.path(diff_image).size
    end
    Then { diff_image_size[0] == 320 }
  end
end
