class CustomError < StandardError
end

class InvalidDomainsError < CustomError
end

class MissingRequiredPropertyError < CustomError
end
