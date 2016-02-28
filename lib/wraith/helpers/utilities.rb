require "wraith/helpers/custom_exceptions"

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
