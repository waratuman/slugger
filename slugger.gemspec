# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slugger/version'

Gem::Specification.new do |spec|
  spec.name          = "slugger"
  spec.version       = Slugger::VERSION
  spec.authors       = ["James R. Bracy"]
  spec.email         = ["waratuman@gmail.com"]
  spec.description   = %q{Rails plugin for slugging models.}
  spec.summary       = %q{Simple slugging for Rails models}
  spec.homepage      = "http://github.com/waratuman/slugger"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '~> 4.0.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'minitest', '>= 4.4.0'
  spec.add_development_dependency 'turn'
  spec.add_development_dependency 'sqlite3'

end
