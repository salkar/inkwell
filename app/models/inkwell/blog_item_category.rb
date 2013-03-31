module Inkwell
  if ::Inkwell::Engine::config.respond_to?('category_table')
    class BlogItemCategory < ActiveRecord::Base
      attr_accessible :blog_item_id, :category_id, :blog_item_created_at, :item_type, :item_id
    end
  end
end