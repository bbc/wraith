require 'wraith'
require 'image_size'

class Wraith::CropImages
  attr_reader :dir

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
    @logger = @wraith.logger
    @dir = @wraith.directory
  end

  def crop
    crop_value(base_height, compare_height, @compare, @base)
  end

  def height
    crop_value(base_height, compare_height, base_height, compare_height)
  end

  def base_height
    find_heights(@base)
  end

  def compare_height
    find_heights(@compare)
  end

  def crop_images
    files = Dir.glob("#{dir}/*/*.png").sort
    until files.empty?
      @base, @compare = files.slice!(0, 2)
      @logger.debug 'cropping images'
      @wraith.crop_images(crop, height)
    end
  end

  def crop_value(base_height, compare_height, arg3, arg4)
    if base_height > compare_height
      arg3
    else
      arg4
    end
  end

  def find_heights(height)
    File.open(height, 'rb') do |fh|
      size = ImageSize.new(fh.read).size
      height = size[1]
    end
  end
end
