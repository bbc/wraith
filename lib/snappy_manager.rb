require 'snappy'
require 'image_size'

class SnappyManager
  attr_reader :snappy

  def initialize(config)
    @snappy = Snappy.new(config)
  end

  def compare_images
    files = []
    Dir.glob("shots/*/*.png") do |filename|
      files << filename
    end

    while !files.empty?
      base, compare = files.slice!(0, 2)
      diff = base.gsub(/([a-z]+).png$/, 'diff.png')
      snappy.compare_images(base, compare, diff, base.gsub(/([a-z]+).png$/, 'data.txt'))

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
    base_domain = {'label' => snappy.base_domain_label, 'host' => snappy.base_domain}
    compare_domain = {'label' => snappy.comp_domain_label, 'host' => snappy.comp_domain}

    snappy.paths.each do |label, path|
      puts "processing '#{label}' '#{path}'"
      if !path
        path = label
        label = path.gsub('/','_')
      end

      FileUtils.mkdir("shots/#{label}")
      FileUtils.mkdir_p("shots/thumbnails/#{label}")

      snappy.widths.each do |width|
        width = width.to_s
        compare_url = compare_domain['host'] + path
        base_url = base_domain['host'] + path

        compare_file_name = "shots/#{label}/#{width}_#{compare_domain['label']}.png"
        base_file_name = "shots/#{label}/#{width}_#{base_domain['label']}.png"

        snappy.capture_page_image compare_url, width, compare_file_name
        snappy.capture_page_image base_url, width, base_file_name
      end
    end
  end

  def crop_images
    files = []
    Dir.glob("shots/*/*.png") do |filename|
      files << filename
    end

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
          snappy.crop_images(crop, height)
        end
      end
    end
  end

  def generate_thumbnails
    Dir.glob("shots/*/*.png").each do |filename|
      new_name = filename.gsub(/^shots/, 'shots/thumbnails')
      snappy.thumbnail_image(filename, new_name)
    end
  end
end
