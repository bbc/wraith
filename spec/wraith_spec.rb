require "rspec"
require "image_size"
require "helpers"
require "./lib/wraith/cli"

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
      expect(wraith.base_domain).to eq "http://www.bbc.com/afrique"
    end

    it "include compare domain" do
      expect(wraith.comp_domain).to eq "http://www.bbc.com/russian"
    end

    it "include base label" do
      expect(wraith.base_domain_label).to eq "afrique"
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
        saving.capture_page_image(engine, test_url1, 320, test_image1, selector, 'false', 'false')
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

  describe "When generating gallery" do
    let(:gallery) { Wraith::GalleryGenerator.new(config_name, false) }

    it "should not break when there is a `-` in the filename" do
      dirs = gallery.parse_directories 'spec/thumbnails'

      images = [
        {
          :filename => 'test/test_image-1.png',
          :thumb    => 'thumbnails/test/test_image-1.png'
        },
        {
          :filename => 'test/test_image-2.png',
          :thumb    => 'thumbnails/test/test_image-2.png'
        },
        {
          :filename => 'test/test_image--modifier.png',
          :thumb    => 'thumbnails/test/test_image--modifier.png'
        },
        {
          :filename => 'test/test_image__my_name.png',
          :thumb    => 'thumbnails/test/test_image__my_name.png'
        },
        {
          :filename => 'test/test_image_my_name.png',
          :thumb    => 'thumbnails/test/test_image_my_name.png'
        }
      ]

      dirs['test'][0][:variants].each_with_index do |image, i|
        expect(image[:filename]).to eq images[i][:filename]
        expect(image[:thumb]).to eq images[i][:thumb]
      end

      diff = {
        :filename => 'test/test_image-diff.png',
        :thumb    => 'thumbnails/test/test_image-diff.png'
      }

      expect(dirs['test'][0][:diff][:filename]).to eq 'test/test_image-diff.png'
      expect(dirs['test'][0][:diff][:thumb]).to eq 'thumbnails/test/test_image-diff.png'
    end
  end

  describe "When hooking into beforeCapture (CasperJS)" do
    let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--casper.yaml" }
    let(:saving) { Wraith::SaveImages.new(config_name) }
    let(:wraith) { Wraith::Wraith.new(config_name) }
    let(:selector) { "body" }
    let(:before_suite_js) { "spec/js/global.js" }
    let(:before_capture_js) { "spec/js/path.js" }

    it "Executes the global JS before capturing" do
      run_js_then_capture(
        global_js: before_suite_js,
        path_js:   'false',
        output_should_look_like: 'spec/base/global.png',
        engine:    'casperjs'
      )
    end

    it "Executes the path-level JS before capturing" do
      run_js_then_capture(
        global_js: 'false',
        path_js: before_capture_js,
        output_should_look_like: 'spec/base/path.png',
        engine:    'casperjs'
      )
    end

    it "Executes the global JS before the path-level JS" do
      run_js_then_capture(
        global_js: before_suite_js,
        path_js: before_capture_js,
        output_should_look_like: 'spec/base/path.png',
        engine:    'casperjs'
      )
    end
  end

  # @TODO - uncomment and figure out why broken
  # describe "When hooking into beforeCapture (PhantomJS)" do
  #   let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
  #   let(:saving) { Wraith::SaveImages.new(config_name) }
  #   let(:wraith) { Wraith::Wraith.new(config_name) }
  #   let(:selector) { "body" }
  #   let(:before_suite_js) { "../../spec/js/global.js" }
  #   let(:before_capture_js) { "../../spec/js/path.js" }

  #   it "Executes the global JS before capturing" do
  #     run_js_then_capture(
  #       global_js: before_suite_js,
  #       path_js:   'false',
  #       output_should_look_like: 'spec/base/global.png',
  #       engine:    'phantomjs'
  #     )
  #   end

  #   it "Executes the path-level JS before capturing" do
  #     run_js_then_capture(
  #       global_js: 'false',
  #       path_js: before_capture_js,
  #       output_should_look_like: 'spec/base/path.png',
  #       engine:    'phantomjs'
  #     )
  #   end

  #   it "Executes the global JS before the path-level JS" do
  #     run_js_then_capture(
  #       global_js: before_suite_js,
  #       path_js: before_capture_js,
  #       output_should_look_like: 'spec/base/path.png',
  #       engine:    'phantomjs'
  #     )
  #   end
  # end

end
