require "_helpers"

describe "Wraith config validator" do
  let(:config) do
    YAML.load('
      domains:
        test: http://www.bbc.com

      browser: "casperjs"

      directory: some/dir
    ')
  end

  describe "universal, basic validation for all modes" do
    it "should validate a basic config" do
      Wraith::Validate.new(config, { yaml_passed: true }).validate
    end

    it "should complain if the `domains` property is missing" do
      config["domains"] = nil
      expect { Wraith::Validate.new(config, { yaml_passed: true }).validate }.to raise_error MissingRequiredPropertyError
    end

    it "should complain if the `browser` property is missing" do
      config["browser"] = nil
      expect { Wraith::Validate.new(config, { yaml_passed: true }).validate }.to raise_error MissingRequiredPropertyError
    end

    it "should complain if the config file doesn't exist" do
      expect { Wraith::Wraith.new('configs/some_made_up_config.yml') }.to raise_error ConfigFileDoesNotExistError
    end
  end

  describe "validation specific to capture mode" do
    it "should complain if fewer than two domains are specified" do
      expect { Wraith::Validate.new(config, { yaml_passed: true }).validate("capture") }.to raise_error InvalidDomainsError
    end

    it "should complain if more than two domains are specified" do
      config["domains"] = YAML.load('
        test:  http://something.bbc.com
        stage: http://something-else.bbc.com
        live:  http://www.bbc.com
      ')
      expect { Wraith::Validate.new(config, { yaml_passed: true }).validate("capture") }.to raise_error InvalidDomainsError
    end

    it "should be happy if exactly two domains are specified" do
      config["domains"] = YAML.load('
          test:  http://something.bbc.com
          live:  http://www.bbc.com
      ')
      Wraith::Validate.new(config, { yaml_passed: true }).validate("capture")
    end

    it "should fail if no directory is specified" do
      config["domains"] = YAML.load('
          test:  http://something.bbc.com
          live:  http://www.bbc.com
      ')
      config["directory"] = nil
      expect { Wraith::Validate.new(config, { yaml_passed: true }).validate("capture") }.to raise_error MissingRequiredPropertyError
    end
  end

  describe "validations specific to history mode" do
    let(:history_conf) do
      config.merge(YAML.load('
        history_dir: "history_shots"
      '))
    end

    it "should complain if more than one domain is specified" do
      history_conf["domains"] = YAML.load('
        test: http://something.bbc.com
        live: http://www.bbc.com
      ')
      expect { Wraith::Validate.new(history_conf, { yaml_passed: true }).validate("history") }.to raise_error InvalidDomainsError
    end

    it "should complain if no history_dir is specified" do
      history_conf["history_dir"] = nil
      expect { Wraith::Validate.new(history_conf, { yaml_passed: true }).validate("history") }.to raise_error MissingRequiredPropertyError
    end

    it "should be happy if a history_dir and one domain is specified" do
      Wraith::Validate.new(history_conf, { yaml_passed: true }).validate("history")
    end
  end

  describe "validations specific to spider mode" do
    let(:spider_conf) do
      YAML.load('
        domains:
          test: http://www.bbc.com

        browser: "casperjs"

        directory: some/dir

        imports: "spider_paths.yml"
      ')
    end

    it "should complain if imports is empty" do
      spider_conf.delete 'imports'
      expect { Wraith::Validate.new(spider_conf, { yaml_passed: true, imports_must_resolve: false }).validate("spider") }.to raise_error MissingRequiredPropertyError
    end

    # @TODO - would be good to get this passing. Right now we get a false positive if you've run `wraith spider` once already - thereby 'paths' being set, and this error being raised.
    # it "should complain if paths is set" do
    #   spider_conf.merge!(YAML.load('
    #     paths:
    #       home: /
    #   '))
    #   expect { Wraith::Validate.new(spider_conf, { yaml_passed: true, imports_must_resolve: false }).validate("spider") }.to raise_error PropertyOutOfContextError
    # end
  end
end
