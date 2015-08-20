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

def run_js_then_capture(config)
  generated_image = 'shots/test/temporary_jsified_image.png'
  saving.capture_page_image('casperjs', test_url1, 320, generated_image, selector, config[:global_js], config[:path_js])
  Wraith::CompareImages.new(config_name).compare_task(generated_image, config[:output_should_look_like], diff_image, data_txt)
  diff = File.open('shots/test/test.txt', "rb").read
  expect(diff).to eq '0.0'
end