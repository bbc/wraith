module CommandLineImageTool

  def capture_page_image(browser, url, width, file_name)
    puts `"#{browser}" #{@config['phantomjs_options']} "#{snap_file}" "#{url}" "#{width}" "#{file_name}"`
  end

  def compare_images(base, compare, output, info)
    puts `compare -fuzz #{fuzz} -metric AE -highlight-color blue #{base} #{compare} #{output} 2>#{info}`
  end

  def self.crop_images(crop, height)

    if os.windows?
      puts `convert #{crop.gsub('/', '\\')} -background none -extent 0x#{height} #{crop.gsub('/', '\\')}`
    else
      puts `convert #{crop} -background none -extent 0x#{height} #{crop}`
    end

  end

  def thumbnail_image(png_path, output_path)
    if os.windows?
      `convert #{png_path.gsub('/', '\\')} -thumbnail 200 -crop 200x200+0+0 #{output_path}`
    else
      `convert #{png_path} -thumbnail 200 -crop 200x200+0+0 #{output_path}`
    end

  end

end
