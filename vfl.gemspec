# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vfl/version'

Gem::Specification.new do |spec|
  spec.name          = "vfl"
  spec.version       = Vfl::VERSION
  spec.authors       = ["Adhithya Rajasekaran"]
  spec.email         = ["adhithyan15@gmail.com"]
  spec.description   = %q{Vanilla brings Markdown like features to LATEX}
  spec.summary       = %q{Vanilla is a powerful LATEX preprocessor. It aims to reduce the entry barrier and the learning curve for LATEX by simplifying the syntax and also reducing the verbosity of Latex}
  spec.homepage      = "http://adhithyan15.github.io/vanilla/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
