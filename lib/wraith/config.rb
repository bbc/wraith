require "yaml"

class Wraith::Config
  attr_reader :file
  attr_reader :parsed_config

  def initialize(opts)
    @file = File.expand_path(opts[:config])
  end

  def parse!
    @parsed_config = ::YAML.load_file(file)
  end

  def has_option?(sym)
    @parsed_config.has_key?(sym.to_s)
  end

  def method_missing(sym, *args, &block)
    unless args.length == 0
      raise "We never set config options on the fly"
    end

    if !@parsed_config.has_key?(sym.to_s)
      raise "Config option not found"
    end

    @parsed_config[sym.to_s]
  end

  def self.parse(file)
    inst = self.new(:config => file)
    inst.parse!
    inst
  end
end
