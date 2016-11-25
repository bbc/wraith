require "wraith/helpers/custom_exceptions"

def absolute_path_of_dir(filepath)
  path_parts = filepath.split('/')
  path_to_dir = path_parts.first path_parts.size - 1
  path_to_dir.join('/')
end

def convert_to_absolute(filepath)
  if !filepath
    "false"
  elsif filepath[0] == "/"
    # filepath is already absolute. return unchanged
    filepath
  elsif filepath.match(/^[A-Z]:\/(.+)$/)
    # filepath is an absolute Windows path, e.g. C:/Code/Wraith/javascript/global.js. return unchanged
    filepath
  else
    # filepath is relative. it must be converted to absolute
    "#{Dir.pwd}/#{filepath}"
  end
end
