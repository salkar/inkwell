module Inkwell::CanFavorite
  extend ActiveSupport::Concern

  included do
    include Inkwell::TimelineCommon
    has_one :inkwell_subject_counter_cache,
            as: :cached_subject,
            class_name: 'Inkwell::SubjectCounterCache'
    has_many :inkwell_favorites,
             as: :favorite_subject,
             class_name: 'Inkwell::Favorite'

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

    def favorites(
      for_viewer: nil,
      page: nil,
      per: nil,
      padding: nil,
      order: nil)
      result = inkwell_favorites
        .includes(favorite_object: :inkwell_object_counter_cache)
        .order(order || 'created_at DESC')
        .page(page)
        .per(per || favorites_per_page)
      result = result.padding(padding) unless padding.nil?
      inkwell_timeline_for_viewer(result.map(&:favorite_object), for_viewer)
    end

    def favorites_per_page
      Inkwell.favorites_per_page || Inkwell.default_per_page
    end

    def favorites_count
      inkwell_subject_counter_cache&.favorite_count ||
        inkwell_favorites.count
    end

    private

    def check_favoritable(obj)
      unless obj.class.try(:inkwell_favoritable?)
        raise(Inkwell::Errors::NotFavoritable, obj)
      end
    end
  end
end
