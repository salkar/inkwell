module Inkwell
  class FavoriteItem < ActiveRecord::Base
    attr_accessible :item_id, :user_id, :is_comment, :created_at, :updated_at
    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize
  end
end
