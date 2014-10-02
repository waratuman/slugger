require 'active_record'

module Slugger
  extend ActiveSupport::Concern

  included do
    class_attribute :slugger
    ::ActiveRecord::Base.send :include, Slugger::ActiveRecordBaseSluggerExtension
    ::ActiveRecord::Relation.send :include, Slugger::ActiveRecordRelationSluggerExtension
  end

end

require 'slugger/slug'
require 'slugger/history'
require 'slugger/active_record/base'
require 'slugger/active_record/relation'
