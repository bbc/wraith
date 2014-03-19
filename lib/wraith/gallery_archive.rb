#!/usr/bin/env ruby

# Given all the galleries in the snap_history directory, produces a nice looking
# gallery of galleries

require 'erb'
require 'pp'
require 'fileutils'
require 'pry-debugger'

MATCH_FILENAME = /(\S+)_(\S+)\.\S+/
TEMPLATE_LOCATION = "lib/wraith/gallery_template/archive.erb"
BOOTSTRAP_LOCATION = "lib/wraith/gallery_template/bootstrap.min.css"

def parse_directories(dirname)
    dirs = {}
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

    categories.each do |category|
        dirs[category] = {}
        Dir.foreach("#{dirname}/#{category}") do |filename|
            match = MATCH_FILENAME.match(filename)
            if not match.nil? then
                size = match[1].to_i
                group = match[2]
                filepath = category + "/" + filename
                thumbnail = "thumbnails/#{category}/#{filename}"

                if dirs[category][size].nil? then
                    dirs[category][size] = {:variants => []}
                end
                size_dict = dirs[category][size]

                case group
                when 'diff'
                    size_dict[:diff] = {
                        :filename => filepath, :thumb => thumbnail
                    }
                when 'data'
                    size_dict[:data] = File.read("#{dirname}/#{filepath}")
                else
                    size_dict[:variants] << {
                        :name => group,
                        :filename => filepath,
                        :thumb => thumbnail
                    }

                end
                size_dict[:variants].sort! {|a, b| a[:name] <=> b[:name] }
            end
        end
    end

    return dirs
end

def find_archive_directories(dirname)
    Pathname.new(dirname).children.select { |p| p.directory? }.map(&:basename)
end

def generate_html(directories, template, destination)
    template = File.read(template)
    html = ERB.new(template).result
    File.open(destination, 'w') do |outf|
        outf.write(html)
    end
end

if ARGV.length < 1 then
    puts "USAGE: gallery_index.rb <directory>"
    exit 1
end

location = ARGV[0]
#directories = parse_directories(location)
#directories = ["2014-03-12-131744", "2014-03-12-121427"]
directories = find_archive_directories(location)
dest = "#{location}/index.html"


generate_html(directories, TEMPLATE_LOCATION, dest)
FileUtils.cp(BOOTSTRAP_LOCATION, "#{location}/bootstrap.min.css")
