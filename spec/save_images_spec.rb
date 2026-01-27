require "_helpers"
require "image_size"

describe Wraith do
  let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
  let(:config_chrome) { get_path_relative_to __FILE__, "./configs/test_config--chrome.yaml" }
  let(:test_url1) { "http://www.bbc.com/afrique" }
  let(:test_url2) { "http://www.bbc.com/russian" }
  let(:test_image1) { "shots/test/test1.png" }
  let(:test_image_chrome) { "shots_chrome/test/test_chrome.png" }
  let(:test_image_chrome_selector) { "shots_chrome/test/test_chrome_selector.png" }
  let(:test_image2) { "shots/test/test(2).png" }
  let(:diff_image) { "shots/test/test_diff.png" }
  let(:data_txt) { "shots/test/test.txt" }
  let(:selector) { "" }
  let(:saving) { Wraith::SaveImages.new(config_name) }
  let(:saving_chrome) { Wraith::SaveImages.new(config_chrome) }
  let(:wraith) { Wraith::Wraith.new(config_name) }

  before(:each) do
    Wraith::FolderManager.new(config_name).clear_shots_folder
    Wraith::FolderManager.new(config_chrome).clear_shots_folder
    Dir.mkdir("shots/test")
    Dir.mkdir("shots_chrome/test")
  end

  describe "When capturing an image" do
    let(:image_size) { ImageSize.path(test_image1).size }

    it "saves image" do
      capture_image = saving.construct_command(320, test_url1, test_image1, selector, false, false)
      `#{capture_image}`
      expect(image_size[0]).to eq 320
    end
    it "saves image chrome" do
      capture_image = saving_chrome.capture_image_selenium("1080x600", test_url1, test_image_chrome, selector, false, false)
      image_size_chrome = ImageSize.path(test_image_chrome).size
      expect(image_size_chrome[0]).to eq 1080
    end
    it "crops around a selector" do
      selector = "#orb-nav-more"
      capture_image = saving_chrome.capture_image_selenium(1440, test_url1, test_image_chrome_selector, selector, false, false)
      image_size_chrome_selector = ImageSize.path(test_image_chrome_selector).size
      expect(image_size_chrome_selector[0]).to eq 673
      expect(image_size_chrome_selector[1]).to eq 40
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

  describe "when parallelising jobs" do
    context "when something goes wrong" do
      it "creates a dummy invalid image" do
        allow(saving).to receive(:attempt_image_capture).and_raise("boom")
        # Create the image at the original res of the invalid image, so that we
        # can compare its md5 easily
        jobs = [
          ['test', '/test/path', '1500x1500', test_url1, test_image1, nil, nil, nil,
           'invalid1.jpg']
        ]
        saving.parallel_task(jobs)
        # Create the expected image so we can compare them, because they'll
        # differ between imagemagick versions and platforms and so we can't just
        # use a fixture.
        saving.create_invalid_image("shots/test/invalid1.png", 1500, "invalid1.jpg")
        Wraith::CompareImages.new(config_name).compare_task(
          test_image1,
          "shots/test/invalid1.png",
          "shots/test/test_diff.png",
          "shots/test/test.txt"
        )
        diff = File.open("shots/test/test.txt", "rb").read
        expect(diff).to eq "0.0"
      end
    end
  end
end
