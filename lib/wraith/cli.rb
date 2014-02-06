require 'wraith/wraith_logger'

class Wraith::CLI
  def initialize(args, env)
    @env = env

    @logger = Wraith::Logger.new('wraith_cli')
    @logger.info("CLI: #{args.inspect}")
  end

  def start

  end

  protected

  attr_reader :env
end
