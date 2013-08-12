require 'wraith'
require 'image_size'

class WraithManager
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith.new(config)
  end

  def compare_images
    files = []
    Dir.glob("shots/*/*.png") do |filename|
      files << filename
    end
    files.sort!

    while !files.empty?
      base, compare = files.slice!(0, 2)
      diff = base.gsub(/([a-z]+).png$/, 'diff.png')
      wraith.compare_images(base, compare, diff, base.gsub(/([a-z]+).png$/, 'data.txt'))

      contents = ''
      Dir.glob('shots/*/*.txt').each do |f|
        contents += "\n#{f}\n"
        contents += File.read(f)
      end

      File.open("shots/data.txt", "w") {
        |file| file.write(contents)
      }
      puts 'Saved diff'
    end
  end

  def self.reset_shots_folder
      FileUtils.rm_rf('./shots')
      FileUtils.mkdir('shots')
  end

  def reset_shots_folder
    self.class.reset_shots_folder
  end

  def save_images
    base_domain = {'label' => wraith.base_domain_label, 'host' => wraith.base_domain}
    compare_domain = {'label' => wraith.comp_domain_label, 'host' => wraith.comp_domain}

    wraith.paths.each do |label, path|
      puts "processing '#{label}' '#{path}'"
      if !path
        path = label
        label = path.gsub('/','_')
      end

      FileUtils.mkdir("shots/#{label}")
      FileUtils.mkdir_p("shots/thumbnails/#{label}")

      wraith.widths.each do |width|
        width = width.to_s
        compare_url = compare_domain['host'] + path
        base_url = base_domain['host'] + path

        compare_file_name = "shots/#{label}/#{width}_#{compare_domain['label']}.png"
        base_file_name = "shots/#{label}/#{width}_#{base_domain['label']}.png"

        wraith.capture_page_image compare_url, width, compare_file_name
        wraith.capture_page_image base_url, width, base_file_name
      end
    end
  end

  def self.crop_images
    files = []
    Dir.glob("shots/*/*.png") do |filename|
      files << filename
    end
    files.sort!

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
