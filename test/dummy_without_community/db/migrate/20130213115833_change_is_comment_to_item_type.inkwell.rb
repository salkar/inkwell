# This migration comes from inkwell (originally 20130202130030)
class ChangeIsCommentToItemType < ActiveRecord::Migration
  def change
      add_column :inkwell_blog_items, :item_type, :string
      ::Inkwell::BlogItem.where(:is_comment => true).update_all(:item_type => 'c')
      ::Inkwell::BlogItem.where(:is_comment => false).update_all(:item_type => 'p')
      remove_column :inkwell_blog_items, :is_comment

      add_column :inkwell_favorite_items, :item_type, :string
      ::Inkwell::FavoriteItem.where(:is_comment => true).update_all(:item_type => 'c')
      ::Inkwell::FavoriteItem.where(:is_comment => false).update_all(:item_type => 'p')
      remove_column :inkwell_favorite_items, :is_comment

      add_column :inkwell_timeline_items, :item_type, :string
      ::Inkwell::TimelineItem.where(:is_comment => true).update_all(:item_type => 'c')
      ::Inkwell::TimelineItem.where(:is_comment => false).update_all(:item_type => 'p')
      remove_column :inkwell_timeline_items, :is_comment
  end
end