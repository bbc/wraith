class Wraith::PluginHandler
  attr_reader :plugins
  attr_reader :initialized_plugins

  def initialize(plugins = [])
    @plugins = plugins
    @initialized_plugins = []
  end

  def register_plugins
    @plugins.each do |plugin|
      begin
        @initialized_plugins << Wraith::Plugin.const_get("#{plugin.capitalize}").new
      rescue
        raise "Could not find plugin Wraith::Plugin::#{plugin.capitalize}"
      end
    end
  end
end
