# This migration comes from inkwell (originally 20130202130010)
class ChangeTablesForCommunities < ActiveRecord::Migration
  def change
    change_column :inkwell_comments, :users_ids_who_favorite_it, :text, :default => '[]'
    change_column :inkwell_comments, :users_ids_who_comment_it, :text, :default => '[]'
    change_column :inkwell_comments, :users_ids_who_reblog_it, :text, :default => '[]'
    remove_column :inkwell_blog_items, "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
    add_column :inkwell_blog_items, :owner_id, :integer
    add_column :inkwell_blog_items, :is_owner_user, :boolean
    change_column :inkwell_timeline_items, :from_source, :text, :default => '[]', :limit => nil

    if ::Inkwell::Engine::config.respond_to?('community_table')
      add_column ::Inkwell::Engine::config.community_table, :users_ids, :text, :default => '[]'
      add_column ::Inkwell::Engine::config.community_table, :admins_info, :text, :default => '[]'
      add_column ::Inkwell::Engine::config.user_table, :communities_ids, :text, :default => '[]'
      add_column ::Inkwell::Engine::config.user_table, :admin_of, :text, :default => '[]'

      add_column ::Inkwell::Engine::config.community_table, :owner_id, :integer
    end
  end
end