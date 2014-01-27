require 'os'
class Wraith::CommandLineImageTool

  def initialize(pahtnomjs_options, snap_file, fuzz)
    @phantomjs_options = pahtnomjs_options
    @snap_file = snap_file
    @fuzz = fuzz
  end

  def capture_page_image(browser, url, width, file_name)
    puts `"#{browser}" #{@phantomjs_options} "#{@snap_file}" "#{url}" "#{width}" "#{file_name}"`
  end

  def compare_images(base, compare, output, info)
    puts `compare -fuzz #{@fuzz} -metric AE -highlight-color blue #{base} #{compare} #{output} 2>#{info}`
  end

  def crop_images(crop, height)
    path=path(crop)
    puts `convert #{path} -background none -extent 0x#{height} #{path}`

  end

  def thumbnail_image(png_path, output_path)
    `convert #{path(png_path)} -thumbnail 200 -crop 200x200+0+0 #{output_path}`
  end

  def path(orig)
    if OS.windows?
      return orig.gsub('/', '\\')
    end

    orig

  end

end
