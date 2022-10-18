# frozen_string_literal: true

require File.join File.expand_path('lib', __dir__), 'passwordstate/version'

Gem::Specification.new do |spec|
  spec.name          = 'passwordstate'
  spec.version       = Passwordstate::VERSION
  spec.authors       = ['Alexander Olofsson']
  spec.email         = ['alexander.olofsson@liu.se']

  spec.summary       = 'A ruby API client for interacting with a passwordstate server'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/ananace/ruby-passwordstate'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_dependency 'logging', '~> 2'
  spec.add_dependency 'rubyntlm', '~> 0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
