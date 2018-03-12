module Slugger
  module ActiveRecord
    module Relation

      def find(*ids)
        return super if !self.ancestors.include?(Slugger)

        id_m = case columns_hash[primary_key].type
        when 'uuid', :uuid
          Slugger::ID::UUID
        when 'integer', :integer
          Slugger::ID::Integer
        else
          raise "Unsupported column type for slugger."
        end

        friendly = ids.all? { |id| id_m.friendly?(id) }

        if !friendly
          return super
        elsif ids.size == 1
          find_by_slug!(ids.first)
        else
          where(slug: ids)
        end
      end

    end
  end
end
