#!/usr/bin/env ruby

# Given all the screenshots in the shots/ directory, produces a nice looking 
# gallery

require 'erb'
require 'pp'
require 'fileutils'

MATCH_FILENAME = /(\S+)_(\S+)\.\S+/

def parse_directories(dirname)
    dirs = {}
    Dir.foreach(dirname) do |category|
        if category != '.' and category != '..' and File.directory? "#{dirname}/#{category}" then
            dirs[category] = {}

            Dir.foreach("#{dirname}/#{category}") do |filename| 
                match = MATCH_FILENAME.match(filename)
                if not match.nil? then
                    size = match[1].to_i
                    group = match[2]
                    filepath = category + "/" + filename

                    if not dirs[category].key? size
                        dirs[category][size] = {:variants => []}
                    end
                    size_dict = dirs[category][size]

                    case group
                    when 'diff'
                        size_dict[:diff] = filepath
                    when 'data'
                        size_dict[:data] = File.read("#{dirname}/#{filepath}")
                    else
                        size_dict[:variants] << {
                            :name => group, :filename => filepath
                        }
                    end
                    size_dict[:variants].sort! {|a, b| a[:name] <=> b[:name]}
                end
            end
        end
    end
    return dirs
end

def generate_html(directories, destination)
    template = File.open('gallery_template.erb').read
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
directories = parse_directories(location)
dest = "#{location}/gallery.html"

generate_html(directories, "#{location}/gallery.html")
