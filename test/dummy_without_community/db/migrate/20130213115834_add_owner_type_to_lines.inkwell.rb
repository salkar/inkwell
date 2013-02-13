# This migration comes from inkwell (originally 20130202130040)
class AddOwnerTypeToLines < ActiveRecord::Migration
  def change
    add_column :inkwell_blog_items, :owner_type, :string
    ::Inkwell::BlogItem.where(:is_owner_user => true).update_all(:owner_type => 'u')
    ::Inkwell::BlogItem.where(:is_owner_user => false).update_all(:owner_type => 'c')
    remove_column :inkwell_blog_items, :is_owner_user

    add_column :inkwell_favorite_items, :owner_type, :string
    ::Inkwell::FavoriteItem.update_all(:owner_type => 'u')
    rename_column :inkwell_favorite_items, "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id", :owner_id

    add_column :inkwell_timeline_items, :owner_type, :string
    ::Inkwell::TimelineItem.update_all(:owner_type => 'u')
    rename_column :inkwell_timeline_items, "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id", :owner_id
  end
end