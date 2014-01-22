module Slugger
  class Slug < ActiveRecord::Base
    table_name = 'slugs'

    default_scope order(:created_at => :desc)

    belongs_to :model, polymorphic: true

    def to_param
      slug
    end

  end
end