require 'wraith/config'

class Wraith::Images
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Config.new(config)
  end

  def files
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    invalid = File.expand_path('../../assets/invalid.jpg', File.dirname(__FILE__))
    files.each do |filename|
      if File.stat("#{filename}").size == 0
        FileUtils.cp invalid, filename
        puts "#{filename} is invalid"
      end
    end
  end

  def generate_thumbnails
    Dir.glob("#{wraith.directory}/*/*.png").each do |filename|
      new_name = filename.gsub(/^#{wraith.directory}/, "#{wraith.directory}/thumbnails")
      thumbnail_image(filename, new_name)
    end
    puts 'Generating thumbnails'
  end

  def thumbnail_image(png_path, output_path)
    # For compatibility with windows file structures switch commenting on the following 2 lines
    `convert #{png_path} -thumbnail 200 -crop 200x200+0+0 #{output_path}`
    #`convert #{png_path.gsub('/', '\\')} -thumbnail 200 -crop 200x200+0+0 #{output_path}`
  end
end
