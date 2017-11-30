module Inkwell::CanBlogging
  extend ActiveSupport::Concern

  included do
    include Inkwell::TimelineCommon
    has_one :inkwell_subject_counter_cache,
            as: :cached_subject,
            class_name: 'Inkwell::SubjectCounterCache',
            dependent: :delete
    has_many :inkwell_blog_items,
             as: :blog_item_subject,
             class_name: 'Inkwell::BlogItem',
             dependent: :delete_all

    def add_to_blog(obj)
      added_to_blog?(obj) || !!inkwell_blog_items.create(blog_item_object: obj)
    end

    def remove_from_blog(obj)
      check_bloggable(obj)
      !!inkwell_blog_items.where(blog_item_object: obj).destroy_all
    end

    def added_to_blog?(obj)
      check_bloggable(obj)
      inkwell_blog_items.where(blog_item_object: obj).exists?
    end

    def blog(for_viewer: nil, &block)
      result = inkwell_blog_items
        .includes(blog_item_object: :inkwell_object_counter_cache)
      result = block.call(result) if block.present?
      inkwell_timeline_for_viewer(result.map(&:blog_item_object), for_viewer)
    end

    def blog_items_count
      inkwell_subject_counter_cache.try(:blog_items_count) ||
        inkwell_blog_items.count
    end

    private

    def check_bloggable(obj)
      unless obj.class.try(:inkwell_can_be_blogged?)
        raise(Inkwell::Errors::NotBloggable, obj)
      end
    end
  end

  module ClassMethods
    def inkwell_can_blogging?
      true
    end
  end
end
