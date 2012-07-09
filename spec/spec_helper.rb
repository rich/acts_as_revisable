$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'acts_as_revisable'
require 'rspec'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

RSpec.configure do |config|
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :disabled => true
  config.color_enabled = true

  # so we can use `:vcr` rathaner than `:vcr => true`;
  # in RSpec 3 this will no longer be necessary.
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:all) do
  end
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :people do |t|
      t.string :name, :revisable_name, :revisable_type
      t.text :notes
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number, :project_id
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end

    create_table :projects do |t|
      t.string :name, :unimportant, :revisable_name, :revisable_type
      t.text :notes
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end

    create_table :foos do |t|
      t.string :name, :revisable_name, :revisable_type
      t.text :notes
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number, :project_id
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end

    create_table :posts do |t|
      t.string :name, :revisable_name, :revisable_type, :type
      t.boolean :revisable_is_current
      t.integer :revisable_original_id, :revisable_branched_from_id, :revisable_number
      t.datetime :revisable_current_at, :revisable_revised_at, :revisable_deleted_at
      t.timestamps
    end
  end
end

setup_db

def cleanup_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("delete from #{table}")
  end
end

class Person < ActiveRecord::Base
  belongs_to :project

  acts_as_revisable do
    revision_class_name "OldPerson"
    on_delete :revise
  end
end

class OldPerson < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "Person"
    clone_associations :all
  end
end

class Project < ActiveRecord::Base
  has_many :people

  acts_as_revisable do
    revision_class_name "Session"
    except :unimportant
  end
end

class Session < ActiveRecord::Base
  acts_as_revision do
    revisable_class_name "Project"
    clone_associations :all
  end
end

class Foo < ActiveRecord::Base
  acts_as_revisable :generate_revision_class => true, :no_validation_scoping => true

  validates_uniqueness_of :name
end

class Post < ActiveRecord::Base
  acts_as_revisable 

  validates_uniqueness_of :name
end

class PostRevision < ActiveRecord::Base
  acts_as_revision
end

class Article < Post
  acts_as_revisable
end

class ArticleRevision < PostRevision
  acts_as_revision
end
