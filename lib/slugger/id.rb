module Slugger
  module ID

    def self.friendly?(klass, id)
      id_m = case klass.columns_hash[klass.primary_key].type
      when 'uuid', :uuid
        Slugger::ID::UUID
      when 'integer', :integer
        Slugger::ID::Integer
      else
        raise "Unsupported column type for slugger."
      end
  
      id_m.friendly?(id)
    end

    module Integer
      def self.friendly?(value)
        value.respond_to?(:to_i) && value.to_i.to_s != value.to_s
      end
    end

    module UUID
      def self.friendly?(value)
        ![
          /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\Z/,
          /\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\Z/,
          /\A\{[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\}\Z/,
          /\A[0-9a-f]{32}\Z/,
          /\A[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}\Z/,
          /\A\{[0-9a-f]{8}-[0-9a-f]{8}-[0-9a-f]{8}-[0-9a-f]{8}\}\Z/
        ].any? { |r| value.match(r) }
      end
    end

  end
end