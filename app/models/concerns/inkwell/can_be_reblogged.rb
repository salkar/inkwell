module Inkwell::CanBeReblogged
  extend ActiveSupport::Concern

  included do
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

    # def favorited_by(&block)
    #   result = inkwell_favorited
    #     .includes(favorite_subject: :inkwell_subject_counter_cache)
    #   result = block.call(result) if block.present?
    #   result.map(&:favorite_subject)
    # end
    #
    # def favorited_by?(subject)
    #   check_favorited_by(subject)
    #   inkwell_favorited.where(favorite_subject: subject).exists?
    # end
    #
    # def favorited_count
    #   inkwell_object_counter_cache.try(:favorite_count) ||
    #     inkwell_favorited.count
    # end

    private

    def check_reblogged_by(obj)
      # unless obj.class.try(:inkwell_can_favorite?)
      #   raise(Inkwell::Errors::CannotFavorite, obj)
      # end
    end

    def inkwell_can_be_reblogged_before_destroy
      # ids = favorited_by.map do |subj|
      #   subj.try(:inkwell_subject_counter_cache).try(:id)
      # end.compact
      # Inkwell::SubjectCounterCache.update_counters(
      #   ids,
      #   favorite_count: -1)
    end
  end

  module ClassMethods
    def inkwell_can_be_reblogged?
      true
    end
  end
end
