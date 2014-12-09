require 'erb'
require 'pp'
require 'fileutils'
require 'wraith/wraith'

class Wraith::GalleryGenerator
  attr_reader :wraith

  MATCH_FILENAME = /(\S+)_(\S+)\.\S+/

  TEMPLATE_LOCATION = File.expand_path('gallery_template/gallery_template.erb', File.dirname(__FILE__))
  TEMPLATE_BY_DOMAIN_LOCATION = File.expand_path('gallery_template/gallery_template.erb', File.dirname(__FILE__))
  BOOTSTRAP_LOCATION = File.expand_path('gallery_template/bootstrap.min.css', File.dirname(__FILE__))

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
    @location = wraith.directory
    @folder_manager = Wraith::FolderManager.new(config)
  end

  def parse_directories(dirname)
    @dirs = {}
    categories = Dir.foreach(dirname).select do |category|
      if ['.', '..', 'thumbnails'].include? category
        # Ignore special dirs
        false
      elsif File.directory? "#{dirname}/#{category}" then
        # Ignore stray files
        true
      else
        false
      end
    end
    match(categories, dirname)
  end

  def match(categories, dirname)
    categories.each do |category|
      @dirs[category] = {}

      Dir.foreach("#{dirname}/#{category}") do |filename|
        match = MATCH_FILENAME.match(filename)
        unless match.nil?
          matcher(match, filename, dirname, category)
        end
      end
    end
    @folder_manager.tidy_shots_folder(@dirs)
    @failed_shots = @folder_manager.threshold_rate(@dirs)
    sorting_dirs(@dirs)
  end

  def matcher(match, filename, dirname, category)
    @size = match[1].to_i
    @group = match[2]
    @filepath = category + '/' + filename
    @thumbnail = "thumbnails/#{category}/#{filename}"

    if @dirs[category][@size].nil?
      @dirs[category][@size] = { variants: [] }
    end

    size_dict = @dirs[category][@size]

    data_group(@group, size_dict, dirname, @filepath)
  end

  def data_group(group, size_dict, dirname, filepath)
    case group
    when 'diff'
      diff_check(size_dict, filepath)
    when 'data'
      data_check(size_dict, dirname, filepath)
    else
      variant_check(size_dict, group)
    end
  end

  def variant_check(size_dict, group)
    size_dict[:variants] << {
      name: group,
      filename: @filepath,
      thumb: @thumbnail
    }
    size_dict[:variants].sort! { |a, b| a[:name] <=> b[:name] }
  end

  def diff_check(size_dict, filepath)
    size_dict[:diff] = {
      filename: filepath, thumb: @thumbnail
    }
  end

  def data_check(size_dict, dirname, filepath)
    size_dict[:data] = File.read("#{dirname}/#{filepath}").to_f
  end

  def sorting_dirs(dirs)
    if %w(diffs_only diffs_first).include?(wraith.mode)
      @sorted = dirs.sort_by { |_category, sizes| -1 * sizes.max_by { |_size, dict| dict[:data] }[1][:data] }
    else
      @sorted = dirs.sort_by { |category, _sizes| category }
    end
    # The sort has made this into an enumerable, convert it back to a Hash
    Hash[@sorted]
  end

  def generate_html(location, directories, template, destination, path)
    template = File.read(template)
    locals = {
      location: location,
      directories: directories,
      path: path,
      threshold: wraith.threshold
    }
    html = ERB.new(template).result(ErbBinding.new(locals).get_binding)
    File.open(destination, 'w') do |outf|
      outf.write(html)
    end
  end

  def generate_gallery(withPath = '')
    dest = "#{@location}/gallery.html"
    directories = parse_directories(@location)
    generate_html(@location, directories, TEMPLATE_BY_DOMAIN_LOCATION, dest, withPath)
    FileUtils.cp(BOOTSTRAP_LOCATION, "#{@location}/bootstrap.min.css")
    puts 'Gallery generated'
    check_failed_shots
  end

  def check_failed_shots
    if @failed_shots == false
      puts 'Failures detected'
      exit 1
    end
  end

  class ErbBinding < OpenStruct
    def get_binding
      binding
    end
  end
end
