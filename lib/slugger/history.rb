module Slugger
  module History

    def self.included(klass)
      klass.send :include, InstanceMethods
      klass.send :after_save, :set_slug_history
    end

    module InstanceMethods

      def set_slug_history
        if self.slugger[:slug_was] && self.slugger[:slug_was] != self.slug
          Slugger::Slug.create(model: self, slug: self.slugger[:slug_was])
        end
      end

    end

  end
end