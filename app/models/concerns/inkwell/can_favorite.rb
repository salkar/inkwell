module Inkwell::CanFavorite
  extend ActiveSupport::Concern

  included do
    has_many :inkwell_favorites,
             as: :favorite_subject,
             class_name: 'Inkwell::Favorite'

    def favorite(obj)
      return false if obj.blank?
      return true if inkwell_favorites.where(favorite_object: obj).exists?
      inkwell_favorites.create(favorite_object: obj)
    end

    def unfavorite(obj)

    end

    def favorite?(obj)
      return false if obj.blank?
      inkwell_favorites.where(favorite_object: obj).exists?
    end

    def favorites

    end

    def favorites_per_page
      10
    end
  end
end
