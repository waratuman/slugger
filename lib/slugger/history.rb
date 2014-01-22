module Slugger
  module History

    def self.included(klass)
      klass.send :include, InstanceMethods
    end

    module InstanceMethods

      def set_slug
        super

        if self.slugger[:options][:trigger] == :after_save
          if Slugger::Slug.where(:slug => slug, :model_id => self, :model_type => self.class.to_s).count == 0
            Slugger::Slug.create(model: self, slug: slug)
          end
        elsif slug_changed? || new_record?
          Slugger::Slug.create(model: self, slug: slug)
        end
      end

    end

  end
end