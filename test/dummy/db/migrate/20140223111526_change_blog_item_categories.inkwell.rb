# This migration comes from inkwell (originally 20130212130958)
class ChangeBlogItemCategories < ActiveRecord::Migration
  def change
    remove_column :inkwell_blog_item_categories, :item_id
    remove_column :inkwell_blog_item_categories, :item_type
    add_index :inkwell_blog_item_categories, :blog_item_id
    add_index :inkwell_blog_item_categories, :category_id
  end
end