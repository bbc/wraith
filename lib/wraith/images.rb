require 'wraith'

class Wraith::Images
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def files
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    files.each do |filename|
      if File.stat("#{filename}").size == 0
        FileUtils.cp 'lib/wraith/assets/invalid.jpg', "#{filename}"
        puts "#{filename} is invalid"
      end
    end
  end
end
