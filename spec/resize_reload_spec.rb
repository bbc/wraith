require "_helpers"

describe "wraith config" do
  let(:config_name) { get_path_relative_to __FILE__, "./configs/test_config--phantom.yaml" }
  let(:saving) { Wraith::SaveImages.new(config_name) }

  describe "saving images" do
    it "should pass the width plainly to the CLI when running in inefficient mode" do
      prepared_width = saving.prepare_widths_for_cli 432
      expect(prepared_width).to eq 432
    end

    it "should pass an array of widths to CLI when running in efficient mode" do
      prepared_width = saving.prepare_widths_for_cli [432, 21, 100]
      expect(prepared_width).to eq "432,21,100"
    end

    it "should create fewer jobs when in efficient mode" do
      base_config = '
        domains:
          test: http://www.bbc.com
        paths:
          test: /mypage
        directory:
          test
        screen_widths:
          - 320
          - 464
          - 624
      '
      efficient_config = YAML.load(base_config + "
        resize_or_reload: resize
      ")
      efficient_saving = Wraith::SaveImages.new(efficient_config, false, true)
      inefficient_config = YAML.load(base_config + "
        resize_or_reload: reload
      ")
      inefficient_saving = Wraith::SaveImages.new(inefficient_config, false, true)

      efficient_jobs   = efficient_saving.define_jobs
      inefficient_jobs = inefficient_saving.define_jobs

      expect(efficient_jobs.length).to be 1
      expect(inefficient_jobs.length).to be 3 # 1 for each screen width

      # [["test", "/mypage", "320,464,624", "http://www.bbc.com/mypage", "test/MULTI__test.png", " ", "false", "false"]]
      expect(efficient_jobs[0][2]).to eq "320,464,624"

      # [["test", "/mypage", 320, "http://www.bbc.com/mypage", "test/320__test.png", " ", "false", "false"], ["test", "/mypage", 464, "http://www.bbc.com/mypage", "/test/464__test.png", " ", "false", "false"], ["test", "/mypage", 624, "http://www.bbc.com/mypage", "/test/624__test.png", " ", "false", "false"]]
      expect(inefficient_jobs[0][2]).to eq 320
    end
  end
end
