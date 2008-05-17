module FatJam #:nodoc:
  module ActsAsRevisable
    class GemSpecOptions
      HASH = {
        :name => "fatjam-acts_as_revisable",
        :version => FatJam::ActsAsRevisable::VERSION::STRING,
        :summary => "acts_as_revisable enables revision tracking, querying, reverting and branching of ActiveRecord models. Inspired by acts_as_versioned.",
        :email => "cavanaugh@fatjam.com",
        :homepage => "http://github.com/fatjam/acts_as_revisable/tree/master",
        :has_rdoc => true,
        :authors => ["Rich Cavanaugh of JamLab, LLC.", "Stephen Caudill of JamLab, LLC."],
        :files => %w( LICENSE README.rdoc Rakefile ) + Dir["{spec,lib,generators,rails}/**/*"],
        :rdoc_options => ["--main", "README.rdoc"],
        :extra_rdoc_files => ["README.rdoc", "LICENSE"]
      }
    end
  end
end
