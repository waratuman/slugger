module Slugger
  module History

    def self.included(klass)
      klass.send :include, InstanceMethods
      klass.send :after_save, :set_slug_history
    end

    module InstanceMethods

      def set_slug_history
        if Slugger::Slug.where(:slug => slug, :model_id => self.id, :model_type => self.class.to_s).count == 0
          Slugger::Slug.create(model: self, slug: slug)
        end
      end

    end

  end
end