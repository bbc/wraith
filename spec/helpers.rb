def create_diff_image
  wraith.engine.each do |_type, engine|
    saving.capture_page_image(engine, test_url1, 320, test_image1, selector, 'false', 'false')
    saving.capture_page_image(engine, test_url2, 320, test_image2, selector, 'false', 'false')
  end
end

def crop_images
  Wraith::CropImages.new(config_name).crop_images
end

def compare_images
  Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
end
