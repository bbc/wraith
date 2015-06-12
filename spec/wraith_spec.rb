require "rspec"
require "image_size"
require "./lib/wraith/cli"

describe Wraith do
  let(:config_name) { "test_config" }
  let(:test_url1) { "http://www.bbc.com/russian" }
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

  describe "Config" do
    it "returns a Wraith class" do
      expect(wraith).is_a? Wraith::Wraith
    end

    it "when config is loaded" do
      expect(wraith).to respond_to :config
    end

    it "contains shot options" do
      expect(wraith.config).to include "directory" => "shots"
    end
  end

  context "When creating a wraith worker" do
    it "should have 7 config keys" do
      expect(wraith.config.keys.size).to be 7
    end

    it "should have widths" do
      expect(wraith.widths).to eq [320, 600, 1280]
    end

    it "include base domain" do
      expect(wraith.base_domain).to eq "http://www.bbc.com/russian"
    end

    it "include compare domain" do
      expect(wraith.comp_domain).to eq "http://www.bbc.com/russian"
    end

    it "include base label" do
      expect(wraith.base_domain_label).to eq "english"
    end

    it "include compare label" do
      expect(wraith.comp_domain_label).to eq "russian"
    end

    it "include compare label" do
      expect(wraith.paths).to eq("home" => "/", "uk_index" => "/uk")
    end
  end

  describe "When capturing an image" do
    let(:image_size) { ImageSize.path(test_image1).size }

    it "saves image" do
      wraith.engine.each do |_type, engine|
        saving.capture_page_image(engine, test_url1, 320, test_image1, selector)
      end

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

  describe "When generating tumbnails" do
    it "produce thumbnails" do
      create_diff_image
      Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
      Wraith::Thumbnails.new(config_name).generate_thumbnails

      expect(File).to exist("shots/thumbnails/test/test1.png")
      expect(File).to exist("shots/thumbnails/test/test(2).png")
      expect(File).to exist("shots/thumbnails/test/test_diff.png")
    end
  end
end

def create_diff_image
  wraith.engine.each do |_type, engine|
    saving.capture_page_image(engine, test_url1, 320, test_image1, selector)
    saving.capture_page_image(engine, test_url2, 320, test_image2, selector)
  end
end

def crop_images
  Wraith::CropImages.new(config_name).crop_images
end

def compare_images
  Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
end
