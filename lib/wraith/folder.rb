require 'wraith'

class Wraith::ClearShots
  attr_reader :dir

  def initialize(dir)
    @dir = dir
  end

  def clear_shots_folder
    FileUtils.rm_rf("./#{dir}")
    FileUtils.mkdir("#{dir}")
  end
end
