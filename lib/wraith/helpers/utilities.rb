# @TODO - extract more shared functions to this file

def convert_to_absolute(filepath)
  if filepath[0] == '/'
    # filepath is already absolute. return unchanged
    filepath
  else
    # filepath is relative. it must be converted to absolute
    "#{Dir.pwd}/#{filepath}"
  end
end

def verbose_log(message)
  if wraith.verbose
    puts message
  end
end
