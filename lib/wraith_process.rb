require 'wraith_manager'
module WraithProcess

  def self.run(path = nil)
    @config_path = path || default_config

    wraith_manager.reset_shots_folder
    wraith_manager.save_images
    wraith_manager.crop_images
    wraith_manager.compare_images
    wraith_manager.generate_thumbnails
  end

  def self.wraith_manager
    @wraith_manager ||= WraithManager.new(config_from_file)
  end

  def self.config_path
    @config_path
  end

  def self.config_from_file
    YAML::load_file config_with_extension
  end

  def self.config_with_extension
    return @config_path if default_extension_present?
    [@config_path,default_extension].join('.') unless default_extension_present?
  end

  def self.default_extension
    'yaml'
  end

  def self.default_extension_present?
    /\.#{default_extension}$/ =~ @config_path
  end

  def self.default_config
    'config'
  end
    
end
