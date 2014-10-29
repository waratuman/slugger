module Slugger
  module History

    def self.included(klass)
      klass.send :include, InstanceMethods
      klass.send :after_save, :set_slug_history
      klass.send :after_destroy, :set_slug_history
      klass.send(:after_create, :set_slug_history_after_create) if klass.slugger[:options][:trigger] == :after_save
    end

    module InstanceMethods

      def set_slug_history
        if self.slugger[:slug_was] != self.slug
          Slugger::Slug.create(model_type: self.class.name, model_id: self.id, slug: self.slug)
        end
      end

      def set_slug_history_after_create
        if self.slug
          Slugger::Slug.create(model_type: self.class.name, model_id: self.id, slug: self.slug)
        end
      end

    end

  end
end