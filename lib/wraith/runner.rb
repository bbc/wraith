require "fileutils"

class Wraith::Runner
  attr_reader :config

  def initialize(config)
    @config = config

    bin = ENV["WRAITH_RUNNER"] || ::Wraith::Phantom::PHANTOM_PATH

    @phantom = Wraith::Phantom.new(bin)
  end

  def perform
    output = @config.output

    @config.paths.each do |l, p|
      ::FileUtils.mkdir_p("#{output}/#{l}")

      base_uri = "#{@config.base_domain}/#{p}"
      compare_uri = "#{@config.compare_domain}/#{p}"

      @config.screen_widths.each do |w|
        capture(base_uri, w.to_s, "#{output}/#{l}/#{w.to_s}_base.png")
        capture(compare_uri, w.to_s, "#{output}/#{l}/#{w.to_s}_compare.png")

        compare(
          "#{output}/#{l}/#{w.to_s}_base.png",
          "#{output}/#{l}/#{w.to_s}_compare.png",
          "#{output}/#{l}/#{w.to_s}_diff.png"
        )
      end
    end
  end


  private

  def capture(uri, width, output)
    @phantom.run_script("scripts/snap.js", [
      uri, width, output
    ])
  end

  def compare(base, compare, output)
     output = %x( compare -fuzz 20% -metric AE -highlight-color blue #{base} #{compare} #{output} )

     if output.to_i > @config.threshold
       puts "Check diff image: #{output}"
     end
  end
end
