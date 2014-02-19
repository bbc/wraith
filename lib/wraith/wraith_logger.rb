require 'wraith'
require 'wraith/wraith'
require 'log4r'
require 'log4r/yamlconfigurator'

class Wraith::Logger

  LOGGER_CONFIG_FILE_PATH = 'configs/wraith_logger.yaml'

  def initialize(name='wraith')

    if File.exist? LOGGER_CONFIG_FILE_PATH
      config = Log4r::YamlConfigurator
      config.load_yaml_file(LOGGER_CONFIG_FILE_PATH)
    end

    @logger = Log4r::Logger.new(name)
    @name = name


#    set_runtime_level
  end

  def method_missing(method, *args, &block)
    Log4r::Logger.get(@name).send(method, *args, &block)
  end


  def set_runtime_level
    if ENV['WRAITH_LOG'] && !ENV['WRAITH_LOG'].nil?
      require 'log4r/config'

      Log4r.define_levels(*Log4r::Log4rConfig::LogLevels)

      begin
        level = Log4r.const_get(ENV["WRAITH_LOG"].upcase)
        @logger.level = level
      rescue NameError
        $stderr.puts "Invalid WRAITH_LOG: #{ENV['WRAITH_LOG']}"
        exit 1
      end

    end

  end

end
