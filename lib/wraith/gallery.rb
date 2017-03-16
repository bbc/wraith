require "erb"
require "pp"
require "fileutils"
require "wraith/wraith"
require "wraith/helpers/logger"

class Wraith::GalleryGenerator
  include Logging
  attr_reader :wraith

  MATCH_FILENAME = /(\S+)_(\S+)\.\S+/

  def initialize(config, multi)
    @wraith = Wraith::Wraith.new(config)
    @location = wraith.directory
    @multi = multi
    @folder_manager = Wraith::FolderManager.new(config)
  end

  def parse_directories(dirname)
    @dirs = {}
    categories = Dir.foreach(dirname).select do |category|
      if [".", "..", "thumbnails"].include? category
        false
      elsif File.directory? "#{dirname}/#{category}"
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
        matcher(match, filename, dirname, category) unless match.nil?
      end
    end
    @folder_manager.tidy_shots_folder(@dirs)
    @failed_shots = @folder_manager.threshold_rate(@dirs)
    sorting_dirs(@dirs)
  end

  def matcher(match, filename, dirname, category)
    @size = match[1].to_i
    @group = get_group_from_match match
    @filepath = category + "/" + filename
    @thumbnail = "thumbnails/#{category}/#{filename}"
    @url = figure_out_url @group, category

    @dirs[category][@size] = { :variants => [] } if @dirs[category][@size].nil?

    size_dict = @dirs[category][@size]

    data_group(@group, size_dict, dirname, @filepath)
  end

  def figure_out_url(group, category)
    root = wraith.domains["#{group}"]
    return "" if root.nil?
    path = get_path(category)
    url  = root + path
    url
  end

  def get_path(category)
    if wraith.paths
      wraith.paths[category]["path"] || wraith.paths[category]
    else
      logger.debug "Read the spider file...."
      paths = File.read(wraith.spider_file)
      paths[category]["path"] || paths[category]
    end
  end

  def get_group_from_match(match)
    group = match[2]
    dash = match[2].rindex("-")
    group = match[2][dash + 1..-1] unless dash.nil?
    group
  end

  def data_group(group, size_dict, dirname, filepath)
    case group
    when "diff"
      diff_check(size_dict, filepath)
    when "data"
      data_check(size_dict, dirname, filepath)
    else
      variant_check(size_dict, group)
    end
  end

  def variant_check(size_dict, group)
    size_dict[:variants] << {
      :name     => group,
      :filename => @filepath,
      :thumb    => @thumbnail,
      :url      => @url
    }
    size_dict[:variants].sort! { |a, b| a[:name] <=> b[:name] }
  end

  def diff_check(size_dict, filepath)
    size_dict[:diff] = {
      :filename => filepath, :thumb => @thumbnail
    }
  end

  def data_check(size_dict, dirname, filepath)
    size_dict[:data] = File.read("#{dirname}/#{filepath}").to_f
  end

  def sorting_dirs(dirs)
    if %w(diffs_only diffs_first).include?(wraith.mode)
      @sorted = sort_by_diffs dirs
    else
      @sorted = sort_alphabetically dirs
    end
    Hash[@sorted]
  end

  def sort_by_diffs(dirs)
    dirs.sort_by do |_category, sizes|
      size = select_size_with_biggest_diff sizes
      -1 * size[1][:data]
    end
  end

  def select_size_with_biggest_diff(sizes)
    begin
      sizes.max_by { |_size, dict| dict[:data] }
    rescue
      fail MissingImageError
    end
  end

  def sort_alphabetically(dirs)
    dirs.sort_by { |category, _sizes| category }
  end

  def generate_gallery(with_path = "")
    dest = "#{@location}/gallery.html"
    directories = parse_directories(@location)

    template = File.expand_path("gallery_template/#{wraith.gallery_template}.erb", File.dirname(__FILE__))
    generate_html(@location, directories, template, dest, with_path)

    report_gallery_status dest
  end

  def generate_html(location, directories, template, destination, path)
    template = File.read(template)
    locals = {
      :location    => location,
      :directories => directories,
      :path        => path,
      :threshold   => wraith.threshold
    }
    html = ERB.new(template).result(ErbBinding.new(locals).get_binding)
    File.open(destination, "w") do |outf|
      outf.write(html)
    end
  end

  def report_gallery_status(dest)
    logger.info "Gallery generated"
    failed = check_failed_shots
    prompt_user_to_open_gallery dest
    exit 1 if failed
  end

  def check_failed_shots
    if @multi
      return false
    elsif @failed_shots == false
      logger.warn "Failures detected:"

      @dirs.each do |dir, sizes|
        sizes.to_a.sort.each do |size, files|
          file = dir.gsub("__", "/")
          if !files.include?(:diff)
            logger.warn "\t Unable to create a diff image for #{file}"
          elsif files[:data] > wraith.threshold
            logger.warn "\t #{file} failed at a resolution of #{size} (#{files[:data]}% diff)"
          end
        end
      end

      return true
    else
      false
    end
  end

  def prompt_user_to_open_gallery(dest)
    logger.info "\nView the gallery in your browser:"
    logger.info "\t file://" + Dir.pwd + "/" + dest
  end

  class ErbBinding < OpenStruct
    def get_binding
      binding
    end
  end
end
