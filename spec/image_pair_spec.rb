require "_helpers"

describe Wraith do
  describe "When generating pairs of images" do
    it "should return pairs from an unordered list" do
      list = %w(
        shots/index/foo.png
        shots/index/bar.png
        shots/index/bar_latest.png
        shots/index/foo_latest.png
      )

      expect(Logging.logger).to_not receive(:warn)

      image_pairs = Wraith::ImagePairs.from_list(list).pairs

      expect(image_pairs).to eq [
        %w(shots/index/bar.png shots/index/bar_latest.png),
        %w(shots/index/foo.png shots/index/foo_latest.png),
      ]
    end

    it "should not include an unpaired item at the beginning of a sorted list" do
      list = %w(
        shots/index/bar.png
        shots/index/foo.png
        shots/index/foo_latest.png
      )

      expect(Logging.logger).to receive(:warn).with("shots/index/bar.png: Couldn't find paired image. Excluding.")

      image_pairs = Wraith::ImagePairs.from_list(list).pairs

      expect(image_pairs).to eq [
        %w(shots/index/foo.png shots/index/foo_latest.png),
      ]
    end

    it "should not include an unpaired item at the end of a sorted list" do
      list = %w(
        shots/index/bar.png
        shots/index/bar_latest.png
        shots/index/foo.png
      )

      expect(Logging.logger).to receive(:warn).with("shots/index/foo.png: Couldn't find paired image. Excluding.")

      image_pairs = Wraith::ImagePairs.from_list(list).pairs

      expect(image_pairs).to eq [
        %w(shots/index/bar.png shots/index/bar_latest.png),
      ]
    end
  end
end
