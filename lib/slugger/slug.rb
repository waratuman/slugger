module Slugger
  class Slug < ActiveRecord::Base
    table_name = 'slugs'

    belongs_to :model, polymorphic: true

    def to_param
      slug
    end

  end
end