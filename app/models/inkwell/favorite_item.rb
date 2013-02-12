module Inkwell
  class FavoriteItem < ActiveRecord::Base
    attr_accessible :item_id, :owner_id, :item_type, :created_at, :updated_at, :owner_type
    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize
  end
end
