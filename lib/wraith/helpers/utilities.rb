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

def list_debug_information
  wraith_version      = Wraith::VERSION
  command_run         = ARGV.join ' '
  ruby_version        = run_command_safely("ruby -v") || "Ruby not installed"
  phantomjs_version   = run_command_safely("phantomjs --version") || "PhantomJS not installed"
  casperjs_version    = run_command_safely("casperjs --version") || "CasperJS not installed"
  imagemagick_version = run_command_safely("convert -version") || "ImageMagick not installed"

  logger.debug "#################################################"
  logger.debug "  Command run:        #{command_run}"
  logger.debug "  Wraith version:     #{wraith_version}"
  logger.debug "  Ruby version:       #{ruby_version}"
  logger.debug "  ImageMagick:        #{imagemagick_version}"
  logger.debug "  PhantomJS version:  #{phantomjs_version}"
  logger.debug "  CasperJS version:   #{casperjs_version}"
  # @TODO - add a SlimerJS equivalent
  logger.debug "#################################################"
end

def run_command_safely(command)
  begin
    output = `#{command}`
  rescue StandardError
    return false
  end
  output.lines.first.chomp
end
