require 'wraith'
require 'parallel'

class Wraith::Thumbnails
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def generate_thumbnails
    puts 'Generating thumbnails'

    files = Dir.glob("#{wraith.directory}/*/*.png")

    Parallel.each(files, in_processes: Parallel.processor_count) do |filename|
      new_name = filename.gsub(/^#{wraith.directory}/, "#{wraith.directory}/thumbnails")
      wraith.thumbnail_image(filename, new_name)
    end
  end
end
