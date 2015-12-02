require "_helpers"

describe Wraith do
  let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--casper.yaml" }
  let(:test_url1) { "http://www.bbc.com/afrique" }
  let(:diff_image) { "shots/test/test_diff.png" }
  let(:data_txt) { "shots/test/test.txt" }
  let(:saving) { Wraith::SaveImages.new(config_name) }
  let(:wraith) { Wraith::Wraith.new(config_name) }
  let(:selector) { "body" }
  let(:before_suite_js) { "spec/js/global.js" }
  let(:before_capture_js) { "spec/js/path.js" }

  describe "different ways of determining the before_capture file" do
    it "should allow users to specify the relative path to the before_capture file" do
      config = YAML.load '
        browser:        casperjs
        before_capture: javascript/do_something.js
      '
      wraith = Wraith::Wraith.new(config, true)
      # not sure about having code IN the test, but we want to get this right.
      expect(wraith.before_capture).to eq (`pwd`.chomp! + '/javascript/do_something.js')
    end

    it "should allow users to specify the absolute path to the before_capture file" do
      config = YAML.load '
        browser:        casperjs
        before_capture: /Users/some_user/wraith/javascript/do_something.js
      '
      wraith = Wraith::Wraith.new(config, true)
      expect(wraith.before_capture).to eq ('/Users/some_user/wraith/javascript/do_something.js')
    end
  end

  # @TODO - we need tests determining the path to "path-level before_capture hooks"

  describe "When hooking into beforeCapture (CasperJS)" do

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
