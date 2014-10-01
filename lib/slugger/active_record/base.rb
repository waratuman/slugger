module Slugger
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      # TODO: Test
      def to_param
        slug? ? slug : super
      end

      def set_slug
        generated_slug = if self.slugger[:proc].is_a?(Proc)
          if (self.slugger[:proc].arity == 1)
            self.slugger[:proc].call(self)
          else
            self.slugger[:proc].call
          end
        else
          send(self.slugger[:proc])
        end
        generated_slug = generated_slug ? generated_slug.split('/').map(&:parameterize).join('/') : nil

        if self.slugger[:options][:history]
          self.slugger[:slug_was] = self.slug
        end

        if [:before_validation, :after_validation, :before_save, :before_create].include?(self.slugger[:options][:trigger])
          self.slug = generated_slug
        else
          update_column(:slug, generated_slug) if slug != generated_slug
        end
      end

      module ClassMethods

        def slug(method, options={}, &block)
          options = options.with_indifferent_access
          options[:trigger] ||= :after_save
          self.slugger = { :proc => method || block, :options => options }
          self.send(options[:trigger], :set_slug)
          self.send(:include, Slugger::History) if options[:history]
        end

        def find(*ids)
          friendly = -> (id) { id.respond_to?(:to_i) && id.to_i.to_s != id.to_s }
          return super if ids.size > 1 || !ids.all? { |x| friendly.call(x) }

          find_by_slug(ids.first)
        end

      end

    end
  end
end
