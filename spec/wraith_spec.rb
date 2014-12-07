require 'rspec-given'
require 'image_size'
require './lib/wraith/cli'

describe Wraith do
  Given { Wraith::FolderManager.new(config_name).clear_shots_folder }
  Given { Dir.mkdir('shots/test') }
  let(:config_name) { 'test_config' }
  let(:test_url1) { 'http://www.bbc.co.uk/russian' }
  let(:test_url2) { 'http://www.bbc.co.uk/russian' }
  let(:test_image1) { 'shots/test/test1.png' }
  let(:test_image2) { 'shots/test/test2.png' }
  let(:diff_image) { 'shots/test/test_diff.png' }
  let(:data_txt) { 'shots/test/test.txt' }
  let(:selector) { '' }
  let(:saving) { Wraith::SaveImages.new(config_name) }

  When(:wraith) { Wraith::Wraith.new(config_name) }
  Then { wraith.is_a? Wraith::Wraith }

  context 'When creating a wraith worker' do

    Then { wraith.config.keys.size == 7 }
    Then { wraith.widths == [320, 600, 1280] }
    Then { wraith.base_domain == 'http://www.bbc.co.uk/russian' }
    Then { wraith.comp_domain == 'http://www.bbc.co.uk/russian' }
    Then { wraith.base_domain_label == 'english' }
    Then { wraith.comp_domain_label == 'russian' }
    Then { wraith.paths == { 'home' => '/', 'uk_index' => '/uk' } }
  end

  context 'When capturing an image' do
    # capture_page_image
    When do
      wraith.engine.each do |_type, engine|
        saving.capture_page_image(engine, test_url1, 320, test_image1, selector)
      end
    end
    When(:image_size) { ImageSize.path(test_image1).size }
    Then { image_size[0] == 320 }
  end

  context 'When comparing images' do
    When(:diff_image_size) do
      wraith.engine.each do |_type, engine|
        saving.capture_page_image(engine, test_url1, 320, test_image1, selector)
        saving.capture_page_image(engine, test_url2, 320, test_image2, selector)
      end
      Wraith::CropImages.new(config_name).crop_images
      Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
      ImageSize.path(diff_image).size
    end
    Then { diff_image_size[0] == 320 }
  end

  context 'When generating tumbnails' do
    When do
      wraith.engine.each do |_type, engine|
        saving.capture_page_image(engine, test_url1, 320, test_image1, selector)
        saving.capture_page_image(engine, test_url2, 320, test_image2, selector)
      end
      Wraith::CropImages.new(config_name).crop_images
      Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
      Wraith::Thumbnails.new(config_name).generate_thumbnails
    end
    Then { File.exist?('shots/thumbnails/test/test1.png') && File.exist?('shots/thumbnails/test/test2.png') && File.exist?('shots/thumbnails/test/test_diff.png') }
  end
end
