require "rspec"
require "./lib/wraith/cli"

def create_diff_image
  capture_image = saving.construct_command(320, test_url1, test_image1, selector, 'false', 'false')
  `#{capture_image}`
  capture_image = saving.construct_command(320, test_url2, test_image2, selector, 'false', 'false')
  `#{capture_image}`
end

def crop_images
  Wraith::CropImages.new(config_name).crop_images
end

def compare_images
  Wraith::CompareImages.new(config_name).compare_task(test_image1, test_image2, diff_image, data_txt)
end

def run_js_then_capture(config)
  generated_image = 'shots/test/temporary_jsified_image.png'
  capture_image = saving.construct_command(320, test_url1, generated_image, selector, config[:global_js], config[:path_js])
  `#{capture_image}`
  Wraith::CompareImages.new(config_name).compare_task(generated_image, config[:output_should_look_like], diff_image, data_txt)
  diff = File.open('shots/test/test.txt', "rb").read
  expect(diff).to eq '0.0'
end

def get_path_relative_to(current_file, file_to_find)
  File.expand_path(File.join(File.dirname(current_file), file_to_find))
end
