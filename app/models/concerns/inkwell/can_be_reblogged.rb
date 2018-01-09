module Inkwell::CanBeReblogged
  extend ActiveSupport::Concern

  included do
    attr_accessor :reblogged_in_timeline
    has_one :inkwell_object_counter_cache,
             as: :cached_object,
             class_name: 'Inkwell::ObjectCounterCache',
             dependent: :delete
    has_many :inkwell_reblogged,
             ->{ where(reblog: true) },
             as: :blog_item_object,
             class_name: 'Inkwell::BlogItem',
             dependent: :delete_all
    before_destroy :inkwell_can_be_reblogged_before_destroy, prepend: true

    def reblogged_by(&block)
      result = inkwell_reblogged
        .includes(blog_item_subject: :inkwell_subject_counter_cache)
      result = block.call(result) if block.present?
      result.map(&:blog_item_subject)
    end

    def reblogged_by?(subject)
      check_reblogged_by(subject)
      subject.reblog?(self)
    end

    def reblogged_count
      # move to &. when ruby supported version starts 2.3 or upper version
      (inkwell_object_counter_cache &&
        inkwell_object_counter_cache.reblog_count) ||
        inkwell_reblogged.count
    end

    private

    def check_reblogged_by(obj)
      unless obj.class.try(:inkwell_can_reblog?)
        raise(Inkwell::Errors::CannotReblog, obj)
      end
    end

    def inkwell_can_be_reblogged_before_destroy
      ids = reblogged_by.map do |subj|
        subj.try(:inkwell_subject_counter_cache).try(:id)
      end.compact
      Inkwell::SubjectCounterCache.update_counters(
        ids,
        reblog_count: -1)
    end
  end

  module ClassMethods
    def inkwell_can_be_reblogged?
      true
    end
  end
end
