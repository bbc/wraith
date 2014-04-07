require 'wraith'
require 'parallel'

class Wraith::CompareImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def compare_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort
    Parallel.each(files.each_slice(2), :in_processes => 8) do |base, compare|
      diff = base.gsub(/([a-z0-9]+).png$/, 'diff.png')
      info = base.gsub(/([a-z0-9]+).png$/, 'data.txt')
      wraith.compare_images(base, compare, diff, info)
      Dir.glob("#{wraith.directory}/*/*.txt").map { |f| "\n#{f}\n#{File.read(f)}" }
      puts 'Saved diff'
    end
  end
end
