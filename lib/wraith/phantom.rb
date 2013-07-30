class Wraith::Phantom
  PHANTOM_PATH = "phantomjs"
  PHANTOM_MIN_VERSION = "1.8.1"

  def initialize(path = nil)
    @path = path || PHANTOM_PATH
  end

  def version_ok?
    out = %x( #{@path} --version ).strip
    !(Gem::Version.new(PHANTOM_MIN_VERSION) > Gem::Version.new(out))
  end

  def installed?
    begin
      %x( #{@path} --version )
      true
    rescue
      false
    end
  end

  def run_script(script, args = [])
    args = args.join(" ")

    process = fork do
      puts %x( #{@path} --disk-cache=false --max-disk-cache-size=0 #{script} #{args} )
    end

    Process.waitpid(process)
  end
end
