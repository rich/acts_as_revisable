require 'rubygems'
require 'active_support' unless defined? ActiveSupport
require 'active_record' unless defined? ActiveRecord

require 'acts_as_revisable/version.rb'
require 'acts_as_revisable/base'

ActiveRecord::Base.send(:include, WithoutScope::ActsAsRevisable)
