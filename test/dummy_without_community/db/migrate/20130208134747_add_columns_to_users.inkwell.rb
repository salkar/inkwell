# This migration comes from inkwell (originally 20121209124435)
class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column ::Inkwell::Engine::config.user_table, :followers_ids, :text, :default => '[]'
    add_column ::Inkwell::Engine::config.user_table, :followings_ids, :text, :default => '[]'
  end
end
