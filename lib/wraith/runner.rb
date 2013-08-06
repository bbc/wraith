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
      ::FileUtils.mkdir_p("#{output}_#{l}")

      base_uri = "#{@config.base_domain}/#{p}"
      compare_uri = "#{@config.compare_domain}/#{p}"

      @config.screen_widths.each do |w|
        puts "Diffing #{base_uri} to #{compare_uri}"

        capture(base_uri, w.to_s, "#{output}/#{l}/#{w.to_s}_base.png")
        capture(compare_uri, w.to_s, "#{output}/#{l}/#{w.to_s}_compare.png")

        compare(
          "#{output}/#{l}/#{w.to_s}_base.png",
          "#{output}/#{l}/#{w.to_s}_compare.png",
          "#{output}/#{l}/#{w.to_s}_diff.png"
        )

        @config.plugins.each do |pl|
          begin
            plugin = Wraith::Plugin.const_get("#{pl.capitalize}").new
            plugin.perform(
              "#{output}/#{l}/#{w.to_s}_base.png",
              "#{output}/#{l}/#{w.to_s}_compare.png",
              "#{output}/#{l}/#{w.to_s}_diff.png"
            )
          rescue
            raise "Could not find plugin Wraith::Plugin::#{pl}"
          end
        end
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
    `compare -fuzz 20% -metric AE -highlight-color blue #{base} #{compare} #{output}`
  end
end
