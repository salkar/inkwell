module Inkwell
  class FavoriteItem < ActiveRecord::Base
    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize
  end
end
