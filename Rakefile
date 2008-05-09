require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
      files = ['README', 'LICENSE',
               'lib/**/*.rb', 'doc/**/*.rdoc', 'test/*.rb']
      rdoc.rdoc_files.add(files)
      rdoc.main = 'README'
      rdoc.title = 'acts_as_revisable RDoc'
      rdoc.rdoc_dir = 'doc'
      rdoc.options << '--line-numbers' << '--inline-source'
end
