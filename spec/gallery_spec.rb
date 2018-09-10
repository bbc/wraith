require "_helpers"

describe Wraith do
  let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
  let(:gallery) { Wraith::GalleryGenerator.new(config_name, false) }

  describe "When generating gallery" do
    it "should not break when there is a `-` in the filename" do
      dirs = gallery.parse_directories "spec/thumbnails"

      images = [
        {
          :filename => "home/test_image-afrique.png",
          :thumb    => "thumbnails/home/test_image-afrique.png"
        },
        {
          :filename => "home/test_image-russian.png",
          :thumb    => "thumbnails/home/test_image-russian.png"
        }
      ]

      dirs["home"][0][:variants].each_with_index do |image, i|
        expect(image[:filename]).to eq images[i][:filename]
        expect(image[:thumb]).to eq images[i][:thumb]
      end

      expect(dirs["home"][0][:diff][:filename]).to eq "home/test_image-diff.png"
      expect(dirs["home"][0][:diff][:thumb]).to eq "thumbnails/home/test_image-diff.png"
    end
  end

  describe "#figure_out_url" do
    it "returns an empty string if it can't find the domain" do
      expect(gallery.figure_out_url("missing_domain", "home")).to eq ""
    end

    it "returns a full url" do
      expected = "http://www.bbc.com/afrique/"
      expect(gallery.figure_out_url("afrique", "home")).to eq expected
    end

    context "when base_path and compare_path are set" do
      let(:config_name) do
        get_path_relative_to __FILE__,
                            "./configs/test_config--base_compare_paths.yaml"
      end
      let(:gallery) { Wraith::GalleryGenerator.new(config_name, false) }

      it "uses the base path for the first domain" do
        expected = "http://www.bbc.com/afrique/old-home"
        expect(gallery.figure_out_url("afrique", "home")).to eq expected
      end

      it "uses the compare path for the second domain" do
        expected = "http://www.bbc.com/russian/new-home"
        expect(gallery.figure_out_url("russian", "home")).to eq expected
      end
    end
  end
end
