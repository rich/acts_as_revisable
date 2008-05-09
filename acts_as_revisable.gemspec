Gem::Specification.new do |s|
  s.name = "acts_as_revisable"
  s.version = "0.6.2"
  s.summary = "acts_as_revisable enables revision tracking, querying, reverting and branching of ActiveRecord models. Inspired by acts_as_versioned."
  s.email = "cavanaugh@fatjam.com"
  s.homepage = "http://github.com/fatjam/acts_as_revisable/tree/master"
  s.has_rdoc = true
  s.authors = ["Rich Cavanaugh of JamLab, LLC.", "Stephen Caudill of JamLab, LLC."]
  s.files = %w(LICENSE README generators/revisable_migration/revisable_migration_generator.rb generators/revisable_migration/templates/migration.rb lib/acts_as_revisable.rb lib/acts_as_revisable/acts/common.rb lib/acts_as_revisable/acts/revisable.rb lib/acts_as_revisable/acts/revision.rb lib/acts_as_revisable/acts/scoped_model.rb lib/acts_as_revisable/base.rb lib/acts_as_revisable/options.rb lib/acts_as_revisable/quoted_columns.rb lib/acts_as_revisable/version.rb lib/acts_as_revisable/clone_associations.rb rails/init.rb spec/acts_as_revisable_spec.rb spec/spec.opts spec/spec_helper.rb spec/aar_options_spec.rb)
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README", "LICENSE"]
end