require 'active_record'
require 'slugger/id'

module Slugger
  extend ActiveSupport::Concern

  included do
    class_attribute :slugger
  end

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
      if !changes['slug']
        self.slug = generated_slug
      end
    else
      update_column(:slug, generated_slug) if slug != generated_slug
    end
  end

  class_methods do

    def slug(method, options={}, &block)
      options = options.with_indifferent_access
      options[:trigger] ||= :after_save
      self.slugger = { :proc => method || block, :options => options }
      self.send(options[:trigger], :set_slug)
      self.send(:include, Slugger::History) if options[:history]
    end

    def find(*ids)
      id_m = case columns_hash[primary_key].type
      when 'uuid', :uuid
        Slugger::ID::UUID
      when 'integer', :integer
        Slugger::ID::Integer
      else
        raise "Unsupported column type for slugger."
      end

      ids = ids.flatten.compact.uniq

      friendly = ids.all? { |id| id_m.friendly?(id) }

      if !friendly
        return super
      elsif ids.size == 1
        find_by_slug!(ids.first)
      else
        where(slug: ids)
      end
    end

  end

end

require 'slugger/slug'
require 'slugger/history'
require 'slugger/active_record/relation'

class ActiveRecord::AssociationRelation
  include Slugger::ActiveRecord::Relation
end
