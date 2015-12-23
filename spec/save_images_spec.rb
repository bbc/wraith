require "_helpers"
require "image_size"

describe Wraith do
  let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
  let(:test_url1) { "http://www.bbc.com/afrique" }
  let(:test_url2) { "http://www.bbc.com/russian" }
  let(:test_image1) { "shots/test/test1.png" }
  let(:test_image2) { "shots/test/test(2).png" }
  let(:diff_image) { "shots/test/test_diff.png" }
  let(:data_txt) { "shots/test/test.txt" }
  let(:selector) { "" }
  let(:saving) { Wraith::SaveImages.new(config_name) }
  let(:wraith) { Wraith::Wraith.new(config_name) }

  before(:each) do
    Wraith::FolderManager.new(config_name).clear_shots_folder
    Dir.mkdir("shots/test")
  end

  describe "When capturing an image" do
    let(:image_size) { ImageSize.path(test_image1).size }

    it "saves image" do
      capture_image = saving.construct_command(320, test_url1, test_image1, selector, false, false)
      `#{capture_image}`
      expect(image_size[0]).to eq 320
    end
  end

  describe "When comparing images" do
    it "should compare" do
      create_diff_image
      crop_images
      compare_images

      diff = ImageSize.path(diff_image).size

      expect(diff[0]).to eq 320
    end
  end

  describe "When generating thumbnails" do
    it "produce thumbnails" do
      create_diff_image
      crop_images
      Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
      Wraith::Thumbnails.new(config_name).generate_thumbnails

      expect(File).to exist("shots/thumbnails/test/test1.png")
      expect(File).to exist("shots/thumbnails/test/test(2).png")
      expect(File).to exist("shots/thumbnails/test/test_diff.png")
    end
  end
end
