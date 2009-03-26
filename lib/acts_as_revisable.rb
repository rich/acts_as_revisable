$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'activesupport' unless defined? ActiveSupport
require 'activerecord' unless defined? ActiveRecord

require 'acts_as_revisable/version.rb'
require 'acts_as_revisable/base'

ActiveRecord::Base.send(:include, WithoutScope::ActsAsRevisable)
