require 'wraith'

class Wraith::Images
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
    @logger = @wraith.logger
  end

  def files
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    invalid = File.expand_path('../../assets/invalid.jpg', File.dirname(__FILE__))
    files.each do |filename|
      if File.stat("#{filename}").size == 0
        FileUtils.cp invalid, filename
        @logger.warn "#{filename} is invalid"
      end
    end
  end
end
