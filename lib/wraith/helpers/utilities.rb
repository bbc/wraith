require "wraith/helpers/custom_exceptions"

def within_acceptable_limits
  yield
rescue CustomError => e
  logger.error e.message
  # other errors, such as SystemError, will not be caught nicely and will give a stack trace (which we'd need)
end

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
  elsif filepath.match(/^[A-Za-z]:\/(.+)$/)
    # filepath is an absolute Windows path, e.g. C:/Code/Wraith/javascript/global.js. return unchanged
    filepath
  else
    # filepath is relative. it must be converted to absolute
    "#{Dir.pwd}/#{filepath}"
  end
end

def list_debug_information
  wraith_version      = Wraith::VERSION
  command_run         = ARGV.join ' '
  ruby_version        = run_command_safely("ruby -v") || "Ruby not installed"
  phantomjs_version   = run_command_safely("phantomjs --version") || "PhantomJS not installed"
  chromedriver_version   = run_command_safely("chromedriver --version") || "chromedriver not installed"
  casperjs_version    = run_command_safely("casperjs --version") || "CasperJS not installed"
  imagemagick_version = run_command_safely("convert -version") || "ImageMagick not installed"

  logger.debug "#################################################"
  logger.debug "  Command run:        #{command_run}"
  logger.debug "  Wraith version:     #{wraith_version}"
  logger.debug "  Ruby version:       #{ruby_version}"
  logger.debug "  ImageMagick:        #{imagemagick_version}"
  logger.debug "  PhantomJS version:  #{phantomjs_version}"
  logger.debug "  chromedriver version:  #{chromedriver_version}"
  logger.debug "  CasperJS version:   #{casperjs_version}"
  # @TODO - add a SlimerJS equivalent
  logger.debug "#################################################"
end

def run_command_safely(command)
  begin
    output = `#{command}`    
    output.lines.first.chomp
  rescue StandardError
    return false
  end
end
