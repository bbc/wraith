require 'wraith'
require 'image_size'

class Wraith::CropImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def crop_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    until files.empty?
      @base, @compare = files.slice!(0, 2)
      base
    end
  end

  def base
    File.open(@base, 'rb') do |fh|
      new_base_height = ImageSize.new(fh.read).size
      @base_height = new_base_height[1]
      compare
    end
  end

  def compare
    File.open(@compare, 'rb') do |fh|
      new_compare_height = ImageSize.new(fh.read).size
      @compare_height = new_compare_height[1]
      cropping
    end
  end

  def cropping
    if @base_height > @compare_height
      height = @base_height
      crop = @compare
    else
      height = @compare_height
      crop = @base
    end

    puts 'cropping images'
    Wraith::Wraith.crop_images(crop, height)
  end
end
