# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "slugger"
  spec.version       = '0.1.2'
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

  spec.add_dependency 'railties', '>= 5.2', '< 7'
  spec.add_dependency 'activerecord', '>= 5.2', '< 7'
  spec.add_dependency 'activesupport', '>= 5.2', '< 7'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rails', '>= 5.2', '< 7'
  spec.add_development_dependency 'pg'

end
