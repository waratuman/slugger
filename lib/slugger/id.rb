module Slugger
  module ID

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