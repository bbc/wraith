require 'wraith'

class Wraith::ClearShots
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def clear_shots_folder
    FileUtils.rm_rf("./#{wraith.directory}")
    FileUtils.mkdir("#{wraith.directory}")
  end
end