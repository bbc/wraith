require 'wraith'
require 'image_size'
require 'parallel'

class Wraith::CropImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def crop_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort

    Parallel.each(files.each_slice(2), in_processes: Parallel.processor_count) do |base, compare|
      puts 'cropping images'

      base_height    = image_height(base)
      compare_height = image_height(compare)

      if base_height > compare_height
        image_to_crop     = compare
        height_to_crop_to = base_height
      else
        image_to_crop     = base
        height_to_crop_to = compare_height
      end

      Wraith::Wraith.crop_images(image_to_crop, height_to_crop_to)
    end
  end

  def image_height(image)
    File.open(image, 'rb') do |fh|
      size = ImageSize.new(fh.read).size
      size[1]
    end
  end
end
