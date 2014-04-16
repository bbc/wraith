require 'wraith/config'
require 'image_size'
require 'open3'

class CompareImages
  attr_reader :wraith

  def initialize(config)
    @wraith = WraithConfig.new(config)
  end

  def compare_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    until files.empty?
      base, compare = files.slice!(0, 2)
      diff = base.gsub(/([a-z0-9]+).png$/, 'diff.png')
      info = base.gsub(/([a-z0-9]+).png$/, 'data.txt')
      compare_task(base, compare, diff, info)
      Dir.glob("#{wraith.directory}/*/*.txt").map { |f| "\n#{f}\n#{File.read(f)}" }
      puts 'Saved diff'
    end
  end

  def percentage(img_size, px_value, info)
    pixel_count = (px_value / img_size) * 100
    rounded = pixel_count.round(2)
    File.open(info, 'w') { |file| file.write(rounded) }
  end

  def compare_task(base, compare, output, info)
    cmdline = "compare -fuzz #{wraith.fuzz} -metric AE -highlight-color blue #{base} #{compare} #{output}"
    px_value = Open3.popen3(cmdline) { |stdin, stdout, stderr, wait_thr| stderr.read }.to_f
    img_size = ImageSize.path(output).size.inject(:*)
    percentage(img_size, px_value, info)
  end
end
