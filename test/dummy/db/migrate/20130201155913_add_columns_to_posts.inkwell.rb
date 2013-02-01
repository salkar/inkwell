# This migration comes from inkwell (originally 20121202140816)
class AddColumnsToPosts < ActiveRecord::Migration
  def change
    add_column ::Inkwell::Engine::config.post_table, :users_ids_who_favorite_it, :text, :default => '[]'
    add_column ::Inkwell::Engine::config.post_table, :users_ids_who_comment_it, :text, :default => '[]'
    add_column ::Inkwell::Engine::config.post_table, :users_ids_who_reblog_it, :text, :default => '[]'
  end
end
