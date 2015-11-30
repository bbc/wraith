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
      saving.capture_page_image(wraith.engine, test_url1, 320, test_image1, selector, 'false', 'false')
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
          :filename => 'home/test_image-afrique.png',
          :thumb    => 'thumbnails/home/test_image-afrique.png'
        },
        {
          :filename => 'home/test_image-russian.png',
          :thumb    => 'thumbnails/home/test_image-russian.png'
        }
      ]

      dirs['home'][0][:variants].each_with_index do |image, i|
        expect(image[:filename]).to eq images[i][:filename]
        expect(image[:thumb]).to eq images[i][:thumb]
      end

      diff = {
        :filename => 'home/test_image-diff.png',
        :thumb    => 'thumbnails/home/test_image-diff.png'
      }

      expect(dirs['home'][0][:diff][:filename]).to eq 'home/test_image-diff.png'
      expect(dirs['home'][0][:diff][:thumb]).to eq 'thumbnails/home/test_image-diff.png'
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
