module Inkwell::TimelineCommon
  extend ActiveSupport::Concern

  included do
    private

    def inkwell_timeline_for_viewer(collection, for_viewer)
      if for_viewer.present?
        favorites = Inkwell::Favorite.where(
          favorite_object: collection,
          favorite_subject: for_viewer).map(&:favorite_object)
        reblogs = Inkwell::BlogItem.where(
          blog_item_object: collection,
          blog_item_subject: for_viewer,
          reblog: true).map(&:blog_item_object)
        collection.map do |obj|
          obj.try(:favorited_in_timeline=, obj.in?(favorites))
          obj.try(:reblogged_in_timeline=, obj.in?(reblogs))
          obj
        end
      else
        collection
      end
    end
  end
end
