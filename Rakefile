require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'fileutils'
require 'lib/acts_as_revisable/version'

Rake::RDocTask.new do |rdoc|
  files = ['README.rdoc', 'LICENSE',
           'lib/**/*.rb', 'doc/**/*.rdoc', 'test/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = 'README.rdoc'
  rdoc.title = 'acts_as_revisable RDoc'
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
end

spec = Gem::Specification.new do |s|
  s.name = "fatjam-acts_as_revisable"
  s.version = FatJam::ActsAsRevisable::VERSION::STRING
  s.summary = "acts_as_revisable enables revision tracking, querying, reverting and branching of ActiveRecord models. Inspired by acts_as_versioned."
  s.email = "cavanaugh@fatjam.com"
  s.homepage = "http://github.com/fatjam/acts_as_revisable/tree/master"
  s.has_rdoc = true
  s.authors = ["Rich Cavanaugh of JamLab, LLC.", "Stephen Caudill of JamLab, LLC."]
  s.files = %w( LICENSE README.rdoc Rakefile ) + Dir["{spec,lib,generators,rails}/**/*"]  
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end