# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'somadic/version'

Gem::Specification.new do |spec|
  spec.name          = 'somadic'
  spec.version       = Somadic::VERSION
  spec.authors       = ['Shane Thomas']
  spec.email         = ['shane@devshane.com']
  spec.summary       = %q{Somadic is a terminal-based player for somafm.com and DI.fm}
  spec.description   = %q{Somadic is a terminal-based player for somafm.com and DI.fm.}
  spec.homepage      = 'https://github.com/devshane/somadic'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mono_logger', '~> 1.1'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'pry', '~> 0.10'
end
