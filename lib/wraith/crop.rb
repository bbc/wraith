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
      @base_height = find_heights(@base)
      @compare_height = find_heights(@compare)
      cropping
    end
  end

  def find_heights(height)
    File.open(height, 'rb') do |fh|
      size = ImageSize.new(fh.read).size
      height = size[1]
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
