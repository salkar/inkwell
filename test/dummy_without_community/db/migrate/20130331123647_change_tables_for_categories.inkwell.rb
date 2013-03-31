# This migration comes from inkwell (originally 20130212130918)
class ChangeTablesForCategories < ActiveRecord::Migration
  def change
    if ::Inkwell::Engine::config.respond_to?('category_table')
      create_table :inkwell_blog_item_categories do |t|
        t.integer :blog_item_id
        t.integer :category_id
        t.integer :item_id
        t.string :item_type
        t.datetime :blog_item_created_at

        t.timestamps
      end

      add_column :inkwell_blog_items, :category_ids, :text, :limit => nil, :default => "[]"

      add_column ::Inkwell::Engine::config.category_table, :parent_ids, :text, :limit => nil, :default => "[]"
      add_column ::Inkwell::Engine::config.category_table, :child_ids, :text, :limit => nil, :default => "[]"
      add_column ::Inkwell::Engine::config.category_table, :owner_id, :integer
      add_column ::Inkwell::Engine::config.category_table, :owner_type, :string
    end
  end
end