module Inkwell::TimelineCommon
  extend ActiveSupport::Concern

  included do
    private

    def inkwell_timeline_for_viewer(collection, for_viewer)
      if for_viewer.present?
        favorites = Inkwell::Favorite.where(
          favorite_object: collection,
          favorite_subject: for_viewer).map(&:favorite_object)
        collection.map do |obj|
          obj.try(:favorited_in_timeline=, obj.in?(favorites))
          obj
        end
      else
        collection
      end
    end
  end
end
