require 'log4r'

class Wraith::CLI
  def initialize(args, env)
    @env = env

    @logger = Log4r::Logger.new("wraith::cli")
    @logger.info("CLI: #{args.inspect}")
  end

  def start

  end

  protected

  attr_reader :env
end
