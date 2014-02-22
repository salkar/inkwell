# This migration comes from inkwell (originally 20130212130948)
class RefactorCategories < ActiveRecord::Migration
  def change
    if ::Inkwell::Engine::config.respond_to?('category_table')
      add_column ::Inkwell::Engine::config.category_table, :parent_id, :integer
      category_class = Object.const_get ::Inkwell::Engine::config.category_table.to_s.singularize.capitalize
      user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
      community_class = Object.const_get ::Inkwell::Engine::config.community_table.to_s.singularize.capitalize if ::Inkwell::Engine::config.respond_to?('community_table')
      category_class.all.each do |category|
        parent_ids = ActiveSupport::JSON.decode category.parent_ids
        category.parent_id = parent_ids.last
        category.owner_type = begin
          user_class.to_s if category.owner_type == 'u'
          community_class.to_s if category.owner_type == 'c' && community_class
        end
        category.save
      end
      rename_column ::Inkwell::Engine::config.category_table, :owner_id, :categoryable_id
      rename_column ::Inkwell::Engine::config.category_table, :owner_type, :categoryable_type
      add_index ::Inkwell::Engine::config.category_table, [:categoryable_id, :categoryable_type]

      remove_column ::Inkwell::Engine::config.category_table, :parent_ids
      remove_column ::Inkwell::Engine::config.category_table, :child_ids
      add_column ::Inkwell::Engine::config.category_table, :lft, :integer
      add_column ::Inkwell::Engine::config.category_table, :rgt, :integer
      add_column ::Inkwell::Engine::config.category_table, :depth, :integer
      add_index ::Inkwell::Engine::config.category_table, :parent_id
      add_index ::Inkwell::Engine::config.category_table, :lft
      add_index ::Inkwell::Engine::config.category_table, :rgt
      category_class.rebuild!
    end
  end
end