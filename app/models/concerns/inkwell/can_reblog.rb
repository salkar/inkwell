# frozen_string_literal: true

module Inkwell::CanReblog
  extend ActiveSupport::Concern

  included do
    include Inkwell::TimelineCommon
    has_one :inkwell_subject_counter_cache,
            as: :cached_subject,
            class_name: "Inkwell::SubjectCounterCache",
            dependent: :delete
    has_many :inkwell_reblogs,
             -> { where(reblog: true) },
             as: :blog_item_subject,
             class_name: "Inkwell::BlogItem",
             dependent: :delete_all
    before_destroy :inkwell_can_reblog_before_destroy, prepend: true

    def reblog(obj)
      reblog?(obj) || !!inkwell_reblogs.create(blog_item_object: obj)
    end

    def unreblog(obj)
      check_rebloggable(obj)
      !!inkwell_reblogs.where(blog_item_object: obj).destroy_all
    end

    def reblog?(obj)
      check_rebloggable(obj)
      inkwell_reblogs.where(blog_item_object: obj).exists?
    end

    def reblogs(for_viewer: nil, &block)
      result = inkwell_reblogs
        .includes(blog_item_object: :inkwell_object_counter_cache)
      result = block.call(result) if block.present?
      inkwell_timeline_for_viewer(result.map(&:blog_item_object), for_viewer)
    end

    def reblogs_count
      # move to &. when ruby supported version starts 2.3 or upper version
      (inkwell_subject_counter_cache &&
        inkwell_subject_counter_cache.reblog_count) ||
        inkwell_reblogs.count
    end

    private

      def check_rebloggable(obj)
        unless obj.class.try(:inkwell_can_be_reblogged?)
          raise(Inkwell::Errors::NotRebloggable, obj)
        end
      end

      def inkwell_can_reblog_before_destroy
        ids = reblogs.map do |obj|
          obj.try(:inkwell_object_counter_cache).try(:id)
        end.compact
        Inkwell::ObjectCounterCache.update_counters(
          ids,
          reblog_count: -1)
      end
  end

  module ClassMethods
    def inkwell_can_reblog?
      true
    end
  end
end
