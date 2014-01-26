module Inkwell
  class BlogItem < ActiveRecord::Base
    if ::Inkwell::Engine::config.respond_to?('community_table')
      belongs_to ::Inkwell::Engine::config.community_table.to_s.singularize.to_sym, :foreign_key => :owner_id
    end
    belongs_to ::Inkwell::Engine::config.post_table.to_s.singularize.to_sym, :foreign_key => :item_id
  end
end
