# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wraith/version'

Gem::Specification.new do |spec|
  spec.name          = 'wraith'
  spec.version       = Wraith::VERSION
  spec.authors       = ['Dave Blooman', 'Simon Thulbourn', 'Chris Ashton']
  spec.email         = ['david.blooman@gmail.com', 'simon+github@thulbourn.com', 'chrisashtonweb@gmail.com']
  spec.summary       = 'Wraith screenshot comparison tool'
  spec.description   = 'Wraith is a screenshot comparison tool, created by developers at BBC News.'
  spec.homepage      = 'https://github.com/BBC-News/wraith'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'casperjs'

  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'image_size'
  spec.add_runtime_dependency 'mini_magick', "~> 4.8"
  spec.add_runtime_dependency 'anemone'
  spec.add_runtime_dependency 'robotex'
  spec.add_runtime_dependency 'log4r'
  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'parallel'
  spec.add_runtime_dependency 'selenium-webdriver', "~> 3.5"
  spec.add_runtime_dependency 'chromedriver-helper', "~> 1.1"
end
