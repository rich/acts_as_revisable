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
    s.send("#{key.to_s}=",value)
  end
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Generate the static gemspec required for github."
task :generate_gemspec do
  options = FatJam::ActsAsRevisable::GemSpecOptions::HASH.clone
  options[:name] = "acts_as_revisable"
  
  spec = ["Gem::Specification.new do |s|"]
  options.each do |key, value|
    spec << "  s.#{key.to_s} = #{value.inspect}"
  end
  spec << "end"
  
  open("acts_as_revisable.gemspec", "w").write(spec.join("\n"))
end

desc "Install acts_as_revisable"
task :install => :repackage do
    options = FatJam::ActsAsRevisable::GemSpecOptions::HASH.clone
    sh %{sudo gem install pkg/#{options[:name]}-#{spec.version} --no-rdoc --no-ri}
end