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
      ids = ids.flatten.compact.uniq

      friendly = ids.all? { |id| Slugger::ID.friendly?(self, id) }

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

class ActiveRecord::Relation

  def find_one(id)
    if !Slugger::ID.friendly?(self, id)
      return super
    end

    relation = where(slug: id)
    record = relation.take

    raise_record_not_found_exception!(id, 0, 1) unless record

    record
  end

  def find_some(ids)
    ids = ids.flatten.compact.uniq

    friendly = ids.all? { |id| Slugger::ID.friendly?(self, id) }

    if !friendly
      return super
    end

    return find_some_ordered(ids) unless order_values.present?

    result = where(slug: ids).to_a

    expected_size =
      if limit_value && ids.size > limit_value
        limit_value
      else
        ids.size
      end

    # 11 ids with limit 3, offset 9 should give 2 results.
    if offset_value && (ids.size - offset_value < expected_size)
      expected_size = ids.size - offset_value
    end

    if result.size == expected_size
      result
    else
      raise_record_not_found_exception!(ids, result.size, expected_size)
    end
  end
  # include Slugger::ActiveRecord::Relation
end
