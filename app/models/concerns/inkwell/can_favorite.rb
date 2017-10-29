module Inkwell::CanFavorite
  extend ActiveSupport::Concern

  included do
    include Inkwell::TimelineCommon
    has_one :inkwell_subject_counter_cache,
            as: :cached_subject,
            class_name: 'Inkwell::SubjectCounterCache',
            dependent: :delete
    has_many :inkwell_favorites,
             as: :favorite_subject,
             class_name: 'Inkwell::Favorite',
             dependent: :delete_all
    before_destroy :inkwell_before_destroy, prepend: true

    def favorite(obj)
      favorite?(obj) || !!inkwell_favorites.create(favorite_object: obj)
    end

    def unfavorite(obj)
      check_favoritable(obj)
      !!inkwell_favorites.where(favorite_object: obj).destroy_all
    end

    def favorite?(obj)
      check_favoritable(obj)
      inkwell_favorites.where(favorite_object: obj).exists?
    end

    def favorites(for_viewer: nil, &block)
      result = inkwell_favorites
        .includes(favorite_object: :inkwell_object_counter_cache)
      result = block.call(result) if block.present?
      inkwell_timeline_for_viewer(result.map(&:favorite_object), for_viewer)
    end

    def favorites_count
      inkwell_subject_counter_cache.try(:favorite_count) ||
        inkwell_favorites.count
    end

    private

    def check_favoritable(obj)
      unless obj.class.try(:inkwell_can_be_favorited?)
        raise(Inkwell::Errors::NotFavoritable, obj)
      end
    end

    def inkwell_before_destroy
      ids = favorites.map do |obj|
        obj.try(:inkwell_object_counter_cache).try(:id)
      end.compact
      Inkwell::ObjectCounterCache.update_counters(
        ids,
        favorite_count: -1)
    end
  end

  module ClassMethods
    def inkwell_can_favorite?
      true
    end
  end
end
