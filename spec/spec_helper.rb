begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

if ENV['EDGE_RAILS_PATH']
  edge_path = File.expand_path(ENV['EDGE_RAILS_PATH'])
  require File.join(edge_path, 'activesupport', 'lib', 'active_support')
  require File.join(edge_path, 'activerecord', 'lib', 'active_record')
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'acts_as_revisable'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

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