require 'log4r'

if ENV['WRAITH_LOG'] && !ENV['WRAITH_LOG'].nil?
  require 'log4r/config'

  Log4r.define_levels(*Log4r::Log4rConfig::LogLevels)

  begin
    level = Log4r.const_get(ENV["WRAITH_LOG"].upcase)
  rescue NameError
    $stderr.puts "Invalid WRAITH_LOG: #{ENV['WRAITH_LOG']}"
    exit 1
  end

  logger = Log4r::Logger.new('wraith')
  logger.outputters = Log4r::Outputter.stderr
  logger.level = level
  logger = nil
end

module Wraith
  autoload :Environment, 'wraith/environment'
  autoload :CLI, 'wraith/cli'
  autoload :Error, 'wraith/error'
end
