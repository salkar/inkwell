module Inkwell::CanBeBlogged
  extend ActiveSupport::Concern

  included do
    has_one :inkwell_blogged,
             as: :blog_item_object,
             class_name: 'Inkwell::BlogItem',
             dependent: :delete
    before_destroy :inkwell_can_be_blogged_before_destroy, prepend: true

    def blogged_by
      inkwell_blogged.try(:blog_item_subject)
    end

    def blogged_by?(subject)
      check_blogged_by(subject)
      blogged_by == subject
    end

    private

    def check_blogged_by(obj)
      unless obj.class.try(:inkwell_can_blogging?)
        raise(Inkwell::Errors::CannotBlogging, obj)
      end
    end

    def inkwell_can_be_blogged_before_destroy
      if blogged_by.present?
        Inkwell::SubjectCounterCache.update_counters(
          blogged_by.id,
          blog_item_count: -1)
      end
    end
  end

  module ClassMethods
    def inkwell_can_be_blogged?
      true
    end
  end
end
