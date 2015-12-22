require "_helpers"

describe "Wraith config to CLI argument mapping" do
  describe "passing variables to construct_command" do
    let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
    let(:saving) { Wraith::SaveImages.new(config_name) }

    it "should take a load of variables and construct a command" do
      width = saving.prepare_widths_for_cli(320)
      url = 'http://example.com/my-page'
      file_name = 'wraith/my-page/320_phantomjs_latest.png'
      selector = '.my_selector'
      global_before_capture = 'javascript/before_capture.js'
      path_before_capture = 'false'
      command = saving.construct_command(width, url, file_name, selector, global_before_capture, path_before_capture)
      expect(command).to eq "phantomjs  '/Users/ashton/Sites/bbc/wraith/lib/wraith/javascript/phantom.js' 'http://example.com/my-page' '320' 'wraith/my-page/320_phantomjs_latest.png' '.my_selector' 'javascript/before_capture.js' 'false'"
      end

    it "should allow hashtags in selectors" do
      width = saving.prepare_widths_for_cli(320)
      url = 'http://example.com/my-page'
      file_name = 'wraith/my-page/320_phantomjs_latest.png'
      selector = '#some-id'
      global_before_capture = 'javascript/before_capture.js'
      path_before_capture = 'false'
      command = saving.construct_command(width, url, file_name, selector, global_before_capture, path_before_capture)
      expect(command).to eq "phantomjs  '/Users/ashton/Sites/bbc/wraith/lib/wraith/javascript/phantom.js' 'http://example.com/my-page' '320' 'wraith/my-page/320_phantomjs_latest.png' '\\#some-id' 'javascript/before_capture.js' 'false'"
    end

    it "should be able to pass multiple widths at once" do
      width = saving.prepare_widths_for_cli([320, 624, 976])
      url = 'http://example.com/my-page'
      file_name = 'wraith/my-page/320_phantomjs_latest.png'
      selector = '.my_selector'
      global_before_capture = 'javascript/before_capture.js'
      path_before_capture = 'false'
      command = saving.construct_command(width, url, file_name, selector, global_before_capture, path_before_capture)
      expect(command).to eq "phantomjs  '/Users/ashton/Sites/bbc/wraith/lib/wraith/javascript/phantom.js' 'http://example.com/my-page' '320,624,976' 'wraith/my-page/320_phantomjs_latest.png' '.my_selector' 'javascript/before_capture.js' 'false'"
    end
  end
end
