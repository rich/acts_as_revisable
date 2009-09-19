Gem::Specification.new do |s|
  s.summary = "acts_as_revisable enables revision tracking, querying, reverting and branching of ActiveRecord models. Inspired by acts_as_versioned."
  s.has_rdoc = true
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "spec/associations_spec.rb", "spec/branch_spec.rb", "spec/deletable_spec.rb", "spec/find_spec.rb", "spec/general_spec.rb", "spec/options_spec.rb", "spec/quoted_columns_spec.rb", "spec/revert_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/sti_spec.rb", "spec/validations_spec.rb", "lib/acts_as_revisable", "lib/acts_as_revisable/acts", "lib/acts_as_revisable/acts/common.rb", "lib/acts_as_revisable/acts/deletable.rb", "lib/acts_as_revisable/acts/revisable.rb", "lib/acts_as_revisable/acts/revision.rb", "lib/acts_as_revisable/base.rb", "lib/acts_as_revisable/gem_spec_options.rb", "lib/acts_as_revisable/options.rb", "lib/acts_as_revisable/quoted_columns.rb", "lib/acts_as_revisable/validations.rb", "lib/acts_as_revisable/version.rb", "lib/acts_as_revisable.rb", "generators/revisable_migration", "generators/revisable_migration/revisable_migration_generator.rb", "generators/revisable_migration/templates", "generators/revisable_migration/templates/migration.rb", "rails/init.rb"]
  s.email = "rich@withoutscope.com"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.version = "1.1.1"
  s.homepage = "http://github.com/rich/acts_as_revisable"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.name = "acts_as_revisable"
  s.authors = ["Rich Cavanaugh", "Stephen Caudill"]
end