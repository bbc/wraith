class CustomError < StandardError
end

class InvalidDomainsError < CustomError
end

class MissingRequiredPropertyError < CustomError
end

class ConfigFileDoesNotExistError < CustomError
end

class PropertyOutOfContextError < CustomError
end

class InvalidYamlError < CustomError
end

class MissingImageError < CustomError
  def initialize(msg = false)
    default_msg = "Something went wrong! It looks like you're missing some images. Check your output directory and make sure that each path has four files for every screen size (data.txt, diff, base, latest). If in doubt, delete your output directory and run Wraith again."
    msg = default_msg unless msg
    super(msg)
  end
end
