module WithoutScope #:nodoc:
  module ActsAsRevisable
    class GemSpecOptions
      HASH = {
        :name => "rich-acts_as_revisable",
        :version => WithoutScope::ActsAsRevisable::VERSION::STRING,
        :summary => "acts_as_revisable enables revision tracking, querying, reverting and branching of ActiveRecord models. Inspired by acts_as_versioned.",
        :email => "rich@withoutscope.com",
        :homepage => "http://github.com/rich/acts_as_revisable",
        :has_rdoc => true,
        :authors => ["Rich Cavanaugh", "Stephen Caudill"],
        :files => %w( LICENSE README.rdoc Rakefile ) + Dir["{spec,lib,generators,rails}/**/*"],
        :rdoc_options => ["--main", "README.rdoc"],
        :extra_rdoc_files => ["README.rdoc", "LICENSE"]
      }
    end
  end
end
