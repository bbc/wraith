require 'wraith'

class Wraith::Images
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def invalid
    File.expand_path('../../assets/invalid.png', File.dirname(__FILE__))
  end

  def files
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    files.each do |filename|
      if File.stat("#{filename}").size == 0
        FileUtils.cp invalid, filename
        puts "#{filename} is invalid"
      end
    end
  end

  def even_images
    test = Dir["#{wraith.directory}/*/"]
    test.each do |dir|
      count = Dir["#{dir}/*"].length
      is_even?(count, dir)
    end
  end

  def is_even?(files, dir)
    if files.odd?
      FileUtils.cp invalid, dir
      puts "An image is missing"
    end
  end
end
