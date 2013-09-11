#!/usr/bin/env ruby

# Given all the screenshots in the shots/ directory, produces a nice looking 
# gallery

require 'erb'
require 'pp'
require 'fileutils'

MATCH_FILENAME = /(\S+)_(\S+)\.\S+/
TEMPLATE_LOCATION = "gallery/gallery_template.erb"
TEMPLATE_BY_DOMAIN_LOCATION = "gallery/gallery_template.erb"
BOOTSTRAP_LOCATION = "gallery/bootstrap.min.css"

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

def generate_html(domain, directories, template, destination)
    template = File.read(template)
    html = ERB.new(template).result
    File.open(destination, 'w') do |outf|
        outf.write(html)
    end
end

if ARGV.length < 1 then
    puts "USAGE: create_gallery.rb <directory>"
    exit 1
end

location = ARGV[0]
domain = location
directories = parse_directories(location)
dest = "#{location}/gallery.html"

generate_html(domain, directories, TEMPLATE_BY_DOMAIN_LOCATION, dest)
FileUtils.cp(BOOTSTRAP_LOCATION, "#{location}/bootstrap.min.css")