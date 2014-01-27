#!/usr/bin/env ruby

# Given all the screenshots in the shots/ directory, produces a nice looking
# gallery

require 'wraith/gallery_generator'

if ARGV.length < 1 then
    puts "USAGE: create_gallery.rb <directory>"
    exit 1
end

location = ARGV[0]
gallery = Wraith::GalleryGenerator.new(location)
gallery.generate_gallery
