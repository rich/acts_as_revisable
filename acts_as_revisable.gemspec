# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'acts_as_revisable/version'

Gem::Specification.new do |s|
  s.name        = "acts_as_revisable"
  s.version     = WithoutScope::ActsAsRevisable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = "2012-06-28"
  s.authors     = ["Rich Cavanaugh", "Stephen Caudill"]
  s.email       = "rich@withoutscope.com"
  s.homepage    = "http://github.com/chargify/acts_as_revisable"
  s.summary     = "acts_as_revisable enables revision tracking, querying, reverting and branching of ActiveRecord models. Inspired by acts_as_versioned."

  s.required_rubygems_version = ">= 1.3.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  # Runtime Dependencies
  s.add_runtime_dependency('activesupport', '>= 3.2.3')
  s.add_runtime_dependency('activerecord', '>= 3.2.3')

  # Development Dependencies
  s.add_development_dependency('rake', '~> 0.9.2')
  s.add_development_dependency('rspec', '~> 2.10.0')
  s.add_development_dependency('guard-rspec', '~> 1.1.0')
  s.add_development_dependency('growl', '~> 1.0.3')
  s.add_development_dependency('rb-fsevent', '~> 0.9.1')
  s.add_development_dependency('sqlite3', '~> 1.3.6')
end
