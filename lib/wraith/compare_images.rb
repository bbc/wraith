require 'wraith'
require 'image_size'

class Wraith::CompareImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def compare_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    until files.empty?
      base, compare = files.slice!(0, 2)
      diff = base.gsub(/([a-z0-9]+).png$/, 'diff.png')
      info = base.gsub(/([a-z0-9]+).png$/, 'data.txt')
      puts `compare -fuzz #{fuzz} -metric AE -highlight-color blue #{base} #{compare} #{output} 2>#{info}`
      puts 'Saved diff'
      difference(info)
    end
  end

  def difference(info)
    puts "this is #{info}"
    # files = Dir.glob("#{wraith.directory}/*/*.*").sort
    # until files.empty?
    #   search = files.slice!(0, 4)
    #   @txt = search.grep(/^*.txt/).first
    #   image = search.grep(/^*.png/).first
    #   find_size(image)
    #   percentage
    # end
  end

  def percentage
    file = File.open(@txt, 'r+')
    change = file.read.to_i
    file.close
    pixel_count = (change / (@height * @width.to_f)) * 100
    rounded = pixel_count.round(2)
    file = File.open(@txt, 'w')
    file.write(rounded)
    file.close
  end

  def find_size(image)
    File.open(image, 'rb') do |pixel|
      pixel = ImageSize.new(pixel.read).size
      @height = pixel[1]
      @width = pixel[0]
    end
  end
end
