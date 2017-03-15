require "wraith/helpers/logger"

class Wraith::ImagePairs
  include Logging
  include Enumerable

  def initialize(list_of_image_paths)
    @list_of_image_paths = list_of_image_paths
  end

  def self.from_list(list_of_image_paths)
    Wraith::ImagePairs.new(list_of_image_paths)
  end

  def pairs
    @pairs ||= list_to_pairs(@list_of_image_paths)
  end

  def each(&block)
    pairs.each(&block)
  end

private

  # Accepts a list of image paths, and returns an array of
  # pairs of images, where the path of one image is contained
  # within another.
  # Any paths which do not have a partner will be removed from the list
  #
  # For example:
  # snaps/index/an_image.png and snaps/index/an_image_latest.png is a pair
  # snaps/index/an_image.png and snaps/index/another_image.png is not a pair
  def list_to_pairs(list_of_image_paths)
    images = list_of_image_paths.sort

    pairs = []
    index = 0
    while index < images.length - 1
      image = images[index]
      next_image = images[index + 1]

      if one_path_contains_the_other?(image, next_image)
        pairs << [image, next_image]
        # Skip to the next pair
        index += 2
      else
        # Skip to the next image. The current image will
        # not be included in the output
        log_excluded(image)
        index += 1
      end
    end

    log_excluded(images[index]) if index == images.length - 1

    pairs
  end

  def log_excluded(image)
    logger.warn "#{image}: Couldn't find paired image. Excluding."
  end

  def without_file_extension(filename)
    filename.sub(/\.[^.]+$/, '')
  end

  def one_path_contains_the_other?(path1, path2)
    path1_without_extension = without_file_extension(path1)
    path2_without_extension = without_file_extension(path2)

    path1_without_extension.include?(path2_without_extension) \
      || path2_without_extension.include?(path1_without_extension)
  end
end
