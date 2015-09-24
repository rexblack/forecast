# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'forecast/version'

Gem::Specification.new do |spec|
  spec.name          = "forecast"
  spec.version       = Forecast::VERSION
  spec.authors       = ["Rafael Nowrotek"]
  spec.email         = ["mail@benignware.com"]
  spec.summary       = %q{A Forecast-Multi-API-Wrapper with a unified model and integrated caching}
  spec.description   = %q{A Forecast-Multi-API-Wrapper with a unified model and integrated caching}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = ["forecast"]  
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "redis"
  
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"

end
