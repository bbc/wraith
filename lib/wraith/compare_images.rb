require 'wraith'

class Wraith::CompareImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Config.new(config)
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

  def compare_task(base, compare, output, info)
    puts `compare -fuzz #{wraith.fuzz} -metric AE -highlight-color blue #{base} #{compare} #{output} 2>#{info}`
  end
end
