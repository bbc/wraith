class Wraith::Environment
  def initialize(options = {})
    @options = options
  end

  def cli(*args)
    ::Wraith::CLI.new(args.flatten, self).start
  end

  attr_reader :options
end
