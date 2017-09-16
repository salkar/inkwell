module Inkwell::CanBeFavorited
  extend ActiveSupport::Concern

  included do
    attr_accessor :favorited_in_timeline
    has_one :inkwell_object_counter_cache,
             as: :cached_object,
             class_name: 'Inkwell::ObjectCounterCache'
    has_many :inkwell_favorited,
             as: :favorite_object,
             class_name: 'Inkwell::Favorite'

    def favorited_count
      inkwell_object_counter_cache.try(:favorite_count) ||
        inkwell_favorited.count
    end

    def favorited_by(page: nil, per: nil, padding: nil, order: nil)
      result = inkwell_favorites
        .includes(favorite_subject: :inkwell_subject_counter_cache)
        .order(order || 'created_at DESC')
        .page(page).per(per || favorited_by_per_page)
      result = result.padding(padding) unless padding.nil?
      result.map(&:favorite_subject)
    end

    def favorited_by?(subject)
      inkwell_favorited.where(favorite_subject: subject).exists?
    end

    def favorited_by_per_page
      Inkwell.favorited_by_per_page || Inkwell.default_per_page
    end
  end

  module ClassMethods
    def inkwell_favoritable?
      true
    end
  end
end
