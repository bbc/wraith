require "wraith"
require "wraith/helpers/logger"
require "image_size"
require "parallel"
require "shellwords"

class Wraith::CropImages
  include Logging
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def crop_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort

    Parallel.each(files.each_slice(2), :in_processes => Parallel.processor_count) do |base, compare|
      crop_if_necessary base, compare
    end
  end

  def crop_if_necessary(base, compare)
      base_width     = image_dimensions(base)[0]
      base_height    = image_dimensions(base)[1]
      compare_width  = image_dimensions(compare)[0]
      compare_height = image_dimensions(compare)[1]

      if base_height == compare_height and base_width == compare_width
        logger.debug "Both images are exactly #{base_width}x#{base_height} - no cropping required. (#{base}, #{compare})"
        return true
      end

      max_width  = [base_width, compare_width].max
      max_height = [base_height, compare_height].max

      logger.debug "Cropping both images to #{max_width}x#{max_height}. (#{base}, #{compare})"
      [base, compare].each do |image_to_crop|
        run_crop_task(image_to_crop, max_height, max_width)
      end
  end

  def run_crop_task(crop, height, width)
    `convert #{crop.shellescape} -background none -extent #{width}x#{height} #{crop.shellescape}`
  end

  def image_dimensions(image)
    ImageSize.new(File.open(image, "rb").read).size
  end
end
