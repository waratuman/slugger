module Slugger
  class Railtie < Rails::Railtie

    initializer 'slugger' do
      ::ActiveRecord::Base.send :include, Slugger::ActiveRecordBaseSluggerExtension
      ::ActiveRecord::Relation.send :include, Slugger::ActiveRecordRelationSluggerExtension
    end

  end
end