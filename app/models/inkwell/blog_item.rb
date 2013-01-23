module Inkwell
  class BlogItem < ActiveRecord::Base
    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize
  end
end
