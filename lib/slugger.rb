require 'slugger/version'

module Slugger

  def self.included(klass)
    klass.send :extend, ClassMethods
    klass.send :include, InstanceMethods

    klass.after_save :set_slug
  end

  module FinderMethods

    def find(*args)
      friendly = -> (arg) { arg.respond_to?(:to_i) && arg.to_i.to_s != arg.to_s }

      if args.count == 1 && friendly.call(args.first)
        find_by_slug(args)
      else
        super
      end
    end

  end

  module ClassMethods

    def slug(method, &block)
      self.slugger = method || block
    end


    def self.extended(klass)
      klass.send(:class_attribute, :slugger)
      klass.send(:include, Slugger::FinderMethods)
      klass.send(:relation).class.send(:include, Slugger::FinderMethods)
    end

  end

  module InstanceMethods

    def set_slug
      generated_slug = if self.slugger.is_a?(Proc)
        if (self.slugger.arity == 1)
          self.slugger.call(self)
        else
          self.slugger.call
        end
      else
        send(self.slugger)
      end
      generated_slug = generated_slug.parameterize
      update_column(:slug, generated_slug) if slug != generated_slug
    end

  end

end
