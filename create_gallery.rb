#!/usr/bin/env ruby

# Given all the screenshots in the shots/ directory, produces a nice looking 
# gallery

require 'erb'
require 'pp'
require 'fileutils'

MATCH_FILENAME = /.+_(\S+)\.\S+/

def parse_directories(dirname)
    dirs = {}
    Dir.foreach(dirname) do |category|
        if category != '.' and category != '..' and File.directory? "#{dirname}/#{category}" then
            dirs[category] = {:variants => []}
            Dir.foreach("#{dirname}/#{category}") do |filename| 
                match = MATCH_FILENAME.match(filename)
                if not match.nil? then
                    group = match[1]
                    filepath = category + "/" + filename
                    case group
                    when 'diff'
                        dirs[category][:diff] = filepath
                    when 'data'
                    else
                        dirs[category][:variants] << {
                            :name => group, :filename => filepath
                        }
                    end
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
