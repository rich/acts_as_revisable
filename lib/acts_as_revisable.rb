$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'acts_as_revisable/version.rb'
require 'acts_as_revisable/acts/scoped_model'
require 'acts_as_revisable/quoted_columns'
require 'acts_as_revisable/base'

ActiveRecord::Base.send(:include, FatJam::ActsAsScopedModel)
ActiveRecord::Base.send(:include, FatJam::QuotedColumnConditions)
ActiveRecord::Base.send(:include, FatJam::ActsAsRevisable)
