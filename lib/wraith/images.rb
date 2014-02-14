require 'wraith'

class Wraith::Images
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
    @logger = @wraith.logger
  end

  def files
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    files.each do |filename|
      if File.stat("#{filename}").size == 0
        FileUtils.cp 'assets/invalid.jpg', "#{filename}"
        @logger.warn "#{filename} is invalid"
      end
    end
  end
end
