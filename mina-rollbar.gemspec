# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mina/rollbar/version'

Gem::Specification.new do |spec|
  spec.name          = 'mina-rollbar'
  spec.version       = Mina::Rollbar::VERSION
  spec.authors       = ['Nick Veys']
  spec.email         = ['nick@codelever.com']
  spec.summary       = %q{Mina tasks for Rollbar}
  spec.description   = %q{Notify Rollbar of Mina deployments.}
  spec.homepage      = 'https://github.com/code-lever/mina-rollbar'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mina', '~> 1.0'
  spec.add_dependency 'json', '~> 2.1.0'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
end
