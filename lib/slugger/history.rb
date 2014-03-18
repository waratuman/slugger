module Slugger
  module History

    def self.included(klass)
      klass.send :include, InstanceMethods
      klass.send :after_save, :set_slug_history
      klass.send :before_destroy, :set_slug
      klass.send :after_destroy, :set_slug_history
    end

    module InstanceMethods

      def set_slug_history
        if self.slugger[:slug_was] != self.slug
        # if self.slugger[:slug_was] && (self.slugger[:slug_was] != self.slug || self.destroyed?)
          Slugger::Slug.create(model_type: self.class.name, model_id: self.id, slug: self.slug)
        end
      end

    end

  end
end