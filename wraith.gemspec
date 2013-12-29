# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wraith/version'

Gem::Specification.new do |spec|
  spec.name          = "wraith"
  spec.version       = Wraith::VERSION
  spec.authors       = ["Dave Blooman", "Simon Thulbourn"]
  spec.email         = ["david.blooman+wraith@gmail.com", "simon+github@thulbourn.com"]
  spec.summary       = 'Wraith is a screenshot comparison tool, created by developers at BBC News.'
  spec.description   = 'Wraith is a screenshot comparison tool, created by developers at BBC News.'
  spec.homepage      = "http://responsivenews.co.uk"
  spec.license       = "Apache 2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec-given"

  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "image_size"
  spec.add_runtime_dependency "anemone"
  spec.add_runtime_dependency "robotex"
  spec.add_runtime_dependency "selenium-webdriver"
  spec.add_runtime_dependency "nokogiri"
end
