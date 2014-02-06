require 'wraith'
require 'wraith/wraith'
require 'log4r'
require 'log4r/yamlconfigurator'

class Wraith::Logger

  def initialize(name='wraith')
    @logger = Log4r::Logger.new(name)

    if File.exist? 'config/logger.yaml'
      config = YamlConfigurator
      config.load_yaml_file('configs/logger.yaml')
    end

    set_runtime_level
  end

  def method_missing(method, *args, &block)
    @logger.send(method, *args, &block)
  end


  def set_runtime_level
    if ENV['WRAITH_LOG'] && !ENV['WRAITH_LOG'].nil?
      require 'log4r/config'

      Log4r.define_levels(*Log4r::Log4rConfig::LogLevels)

      begin
        level = Log4r.const_get(ENV["WRAITH_LOG"].upcase)
      rescue NameError
        $stderr.puts "Invalid WRAITH_LOG: #{ENV['WRAITH_LOG']}"
        exit 1
      end
      @logger.level = level
    end

  end

end
