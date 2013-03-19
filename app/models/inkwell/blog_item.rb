module Inkwell
  class BlogItem < ActiveRecord::Base
    attr_accessible :item_id, :owner_id, :is_reblog, :item_type, :created_at, :updated_at, :owner_type

    if ::Inkwell::Engine::config.respond_to?('community_table')
      belongs_to ::Inkwell::Engine::config.community_table.to_s.singularize.to_sym, :foreign_key => :owner_id
    end
    belongs_to ::Inkwell::Engine::config.post_table.to_s.singularize.to_sym, :foreign_key => :item_id
  end
end
