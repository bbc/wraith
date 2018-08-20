require "_helpers"

describe "wraith config" do
  let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
  let(:wraith) { Wraith::Wraith.new(config_name) }

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

    it 'returns default values for threads' do
      expect(wraith.threads).to eq 8
    end
     it 'returns default values for settle' do
      expect(wraith.settle).to eq 10
    end

    context 'non-standard config values' do
      let(:config) { YAML.load "browser: phantomjs\nthreads: 2\nsettle: 5"}
      let(:non_standard_wraith)  { Wraith::Wraith.new( config, { yaml_passed: true }) }

      it 'returns overridden value when threads is specified in config' do
        expect(non_standard_wraith.threads).to eq 2
      end

      it 'returns overridden value when settle is specified in config' do
        expect(non_standard_wraith.settle).to eq 5
      end
    end

    it "should be able to import other configs" do
      config_name = get_path_relative_to __FILE__, "./configs/test_config--imports.yaml"
      wraith = Wraith::Wraith.new(config_name)

      # retain the imported config settings
      expect(wraith.paths).to eq("home" => "/", "uk_index" => "/uk")
      # ...but override the imported config in places
      expect(wraith.widths).to eq [1337]
    end
  end

  describe "When creating a wraith worker" do
    it "should have a browser engine defined" do
      expect(wraith.engine).to be_a String
    end

    it "should have a directory defined" do
      expect(wraith.directory).to be_a String
    end

    it "should have domains defined" do
      expect(wraith.domains).to be_a Hash
    end

    it "should have screen widths defined" do
      expect(wraith.widths).to be_a Array
    end

    it "should have paths defined" do
      expect(wraith.paths).to be_a Hash
    end

    it "should have fuzz defined" do
      expect(wraith.fuzz).to be_a String
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

  describe "different ways of initialising browser engine" do
    it "should let us directly specify the engine" do
      config = YAML.load "browser: phantomjs"
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })

      expect(wraith.engine).to eq "phantomjs"
    end

    it "should be backwards compatible with the old way" do
      config = YAML.load '
        browser:
          phantomjs: "casperjs"
      '
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.engine).to eq "casperjs"
    end
  end

  describe "different ways of determining the snap file" do
    it "should calculate the snap file from the engine" do
      config = YAML.load "browser: phantomjs"
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.snap_file).to include "lib/wraith/javascript/phantom.js"

      config = YAML.load "browser: casperjs"
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.snap_file).to include "lib/wraith/javascript/casper.js"
    end

    it "should calculate the snap file in a backwards-compatible way" do
      config = YAML.load '
        browser:
          phantomjs: "casperjs"
      '
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.snap_file).to include "lib/wraith/javascript/casper.js"
    end

    it "should allow users to specify the relative path to their own snap file" do
      config = YAML.load '
        browser:   casperjs
        snap_file: path/to/snap.js
      '
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      # not sure about having code IN the test, but we want to get this right.
      expect(wraith.snap_file).to eq(Dir.pwd + "/path/to/snap.js")
    end

    it "should allow users to specify the absolute path to their own snap file" do
      config = YAML.load '
        browser:   casperjs
        snap_file: /Users/my_username/Sites/bbc/wraith/path/to/snap.js
      '
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.snap_file).to eq("/Users/my_username/Sites/bbc/wraith/path/to/snap.js")
    end
  end

  describe "different modes of efficiency (resize or reload)" do
    it "should trigger efficient mode if resize was specified" do
      config = YAML.load 'resize_or_reload: "resize"'
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.resize)
    end

    it "should fall back to slow mode if reload was specified" do
      config = YAML.load 'resize_or_reload: "reload"'
      wraith = Wraith::Wraith.new(config, { yaml_passed: true })
      expect(wraith.resize).to eq false
    end
  end
end
