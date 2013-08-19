require 'wraith_manager'
module WraithProcess

  def self.run
    wraith_manager.reset_shots_folder

    wraith_manager.save_images

    wraith_manager.crop_images

    wraith_manager.compare_images

    wraith_manager.generate_thumbnails
  end

  def self.wraith_manager
    @wraith_manager ||= WraithManager.new('config')
  end
    
end
