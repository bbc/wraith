require 'wraith'

class Wraith::Images
  attr_reader :dir

  def initialize(dir)
    @dir = dir
  end

  def files
    files = Dir.glob("#{dir}/*/*.png").sort
    files.each do |filename|
      if File.stat("#{filename}").size == 0
        FileUtils.cp 'lib/wraith/assets/invalid.jpg', "#{filename}"
        puts "#{filename} is invalid"
      end
    end
  end
end
