require 'wraith'
require 'image_size'

class WraithManager
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith.new(config)
  end

  def compare_images
    files = Dir.glob("shots/*/*.png").sort

    while !files.empty?
      base, compare = files.slice!(0, 2)
      diff = base.gsub(/([a-z]+).png$/, 'diff.png')
      info = base.gsub(/([a-z]+).png$/, 'data.txt')
      wraith.compare_images(base, compare, diff, info)
      contents = Dir.glob('shots/*/*.txt').collect{|f| "\n#{f}\n#{File.read(f)}"}
      File.open("shots/data.txt", "w") { |file| file.write(contents.join)  }
      puts 'Saved diff'
    end
  end

  def self.reset_shots_folder
      FileUtils.rm_r Dir.glob('./shots/*')
  end

  def reset_shots_folder
    self.class.reset_shots_folder
  end

  def save_images

    wraith.paths.each do |label, path|
      puts "processing '#{label}' '#{path}'"
      if !path
        path = label
        label = path.gsub('/','_')
      end

      FileUtils.mkdir("shots/#{label}")
      FileUtils.mkdir_p("shots/thumbnails/#{label}")

      compare_url = wraith.comp_domain + path
      base_url = wraith.base_domain + path

      wraith.widths.each do |width|

        compare_file_name = "shots/#{label}/#{width}_#{wraith.comp_domain_label}.png"
        base_file_name = "shots/#{label}/#{width}_#{wraith.base_domain_label}.png"

        wraith.capture_page_image compare_url, width, compare_file_name
        wraith.capture_page_image base_url, width, base_file_name
      end
    end
  end

  def self.crop_images
    files = Dir.glob("shots/*/*.png").sort

    while !files.empty?
      base, compare = files.slice!(0, 2)
      File.open(base, "rb") do |fh|
        new_base_height = ImageSize.new(fh.read).size

        base_height = new_base_height[1]

        File.open(compare, "rb") do |fh|
          new_compare_height = ImageSize.new(fh.read).size
          compare_height = new_compare_height[1]

          if base_height > compare_height
            height = base_height
            crop = compare
          else
            height = compare_height
            crop = base
          end

          puts "cropping images"
          Wraith.crop_images(crop, height)
        end
      end
    end
  end

  def crop_images
    self.class.crop_images
  end

  def generate_thumbnails
    Dir.glob("shots/*/*.png").each do |filename|
      new_name = filename.gsub(/^shots/, 'shots/thumbnails')
      wraith.thumbnail_image(filename, new_name)
    end
  end
end
