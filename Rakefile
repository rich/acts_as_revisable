require 'rake/rdoctask'
require 'rake/gempackagetask'

Rake::RDocTask.new do |rdoc|
  files = ['README.rdoc', 'LICENSE',
           'lib/**/*.rb', 'doc/**/*.rdoc', 'test/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = 'README.rdoc'
  rdoc.title = 'acts_as_revisable RDoc'
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
end

spec = eval(File.read(File.join('.','acts_as_revisable.gemspec')))

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end