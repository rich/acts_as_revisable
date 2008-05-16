require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'fileutils'
require 'lib/acts_as_revisable/version'
require 'lib/acts_as_revisable/gem_spec_options'

Rake::RDocTask.new do |rdoc|
  files = ['README.rdoc','LICENSE','lib/**/*.rb','doc/**/*.rdoc','spec/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = 'README.rdoc'
  rdoc.title = 'acts_as_revisable RDoc'
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
end

spec = Gem::Specification.new do |s|
  FatJam::ActsAsRevisable::GemSpecOptions::HASH.each do |key, value|
    s.send(key,value)
  end
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end