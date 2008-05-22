Gem::Specification.new do |s|
  s.rdoc_options = ["--main", "README.rdoc"]
  s.summary = "acts_as_revisable enables revision tracking, querying, reverting and branching of ActiveRecord models. Inspired by acts_as_versioned."
  s.name = "acts_as_revisable"
  s.version = "0.7.3"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.email = "cavanaugh@fatjam.com"
  s.has_rdoc = true
  s.homepage = "http://github.com/fatjam/acts_as_revisable/tree/master"
  s.authors = ["Rich Cavanaugh of JamLab, LLC.", "Stephen Caudill of JamLab, LLC."]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "spec/aar_branch_spec.rb", "spec/aar_find_spec.rb", "spec/aar_general_spec.rb", "spec/aar_options_spec.rb", "spec/aar_quoted_columns_spec.rb", "spec/aar_revert_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "lib/acts_as_revisable", "lib/acts_as_revisable/acts", "lib/acts_as_revisable/acts/common.rb", "lib/acts_as_revisable/acts/revisable.rb", "lib/acts_as_revisable/acts/revision.rb", "lib/acts_as_revisable/acts/scoped_model.rb", "lib/acts_as_revisable/base.rb", "lib/acts_as_revisable/clone_associations.rb", "lib/acts_as_revisable/gem_spec_options.rb", "lib/acts_as_revisable/options.rb", "lib/acts_as_revisable/quoted_columns.rb", "lib/acts_as_revisable/version.rb", "lib/acts_as_revisable.rb", "generators/revisable_migration", "generators/revisable_migration/revisable_migration_generator.rb", "generators/revisable_migration/templates", "generators/revisable_migration/templates/migration.rb", "rails/init.rb"]
end