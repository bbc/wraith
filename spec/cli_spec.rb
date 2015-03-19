require "rspec"
require "./lib/wraith/cli"

describe Wraith::CLI do
  let(:config_name) { "test_config" }
  let(:config_history) { "history" }
  let(:wraith) { Wraith::Wraith.new(config_name) }
  let(:cli) { Wraith::CLI.new }

  describe "#setup" do
    it "should create casper setup files" do
      cli.setup_casper

      expect(File).to exist("configs/component.yaml")
      expect(File).to exist("javascript/casper.js")
    end

    it "should create standard setup files" do
      cli.setup

      expect(File).to exist("configs/config.yaml")
      expect(File).to exist("javascript/snap.js")
    end
  end

  describe "folder actions" do
    it "setup folders" do
      cli.setup_folders(config_name)

      expect(Dir).to exist("shots")
    end
  end

  describe "save images" do
    it 'saves without history' do
      cli.save_images(config_name)

      expect(File).to exist("shots/home/1280_phantomjs_russian.png")
    end

    it 'saves using history' do
      cli.reset_shots(config_history)
      cli.save_images(config_history, true)

      expect(File).to_not exist("shots/home/1280_phantomjs_russian.png")
    end
  end
end
