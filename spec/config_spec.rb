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
  end

  describe "When creating a wraith worker" do

    it "should have a browser engine defined" do
      expect(wraith.engine).to be_a Hash
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

end
