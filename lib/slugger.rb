module Slugger

  def self.included(klass)
    klass.send :extend, ClassMethods
    klass.send :include, InstanceMethods
  end

  module FinderMethods

    def find(*args)
      friendly = -> (arg) { arg.respond_to?(:to_i) && arg.to_i.to_s != arg.to_s }

      if args.count == 1 && friendly.call(args.first)
        find_by_slug!(args)
      else
        super
      end
    end

  end

  module ClassMethods

    def slug(method, options={}, &block)
      options[:trigger] ||= :after_save
      self.slugger = { :proc => method || block, :options => options }
      self.send(options[:trigger], :set_slug)
      self.include Slugger::History if options[:history]
    end


    def self.extended(klass)
      klass.send(:class_attribute, :slugger)
      klass.send(:include, Slugger::FinderMethods)
      klass.send(:relation).class.send(:include, Slugger::FinderMethods)
    end

  end

  module InstanceMethods

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
      generated_slug = generated_slug.split('/').map(&:parameterize).join('/')

      if self.slugger[:options][:trigger] == :before_save
        self.slug = generated_slug
      else
        update_column(:slug, generated_slug) if slug != generated_slug
      end
    end

  end

end

require 'slugger/slug'
require 'slugger/history'