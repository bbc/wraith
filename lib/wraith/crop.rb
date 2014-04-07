require 'wraith'
require 'image_size'
require 'parallel'

class Wraith::CropImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def crop(base, compare)
    crop_value(base_height(base), compare_height(compare), compare, base)
  end

  def height(base, compare)
    crop_value(base_height(base), compare_height(compare), base_height(base), compare_height(compare))
  end

  def base_height(base)
    find_heights(base)
  end

  def compare_height(compare)
    find_heights(compare)
  end

  def crop_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort

    Parallel.each(files.each_slice(2), :in_processes => 8) do |base, compare|
      puts 'cropping images'
      Wraith::Wraith.crop_images(crop(base, compare), height(base, compare))
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
