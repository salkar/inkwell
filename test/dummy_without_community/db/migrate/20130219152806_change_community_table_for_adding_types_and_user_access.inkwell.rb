# This migration comes from inkwell (originally 20130212130878)
class ChangeCommunityTableForAddingTypesAndUserAccess < ActiveRecord::Migration
  def change
    if ::Inkwell::Engine::config.respond_to?('community_table')
      add_column ::Inkwell::Engine::config.community_table, :default_user_access, :string, :default => 'w'
      add_column ::Inkwell::Engine::config.community_table, :writers_ids, :text, :default => '[]'
      add_column ::Inkwell::Engine::config.community_table, :banned_ids, :text, :default => '[]'
      add_column ::Inkwell::Engine::config.community_table, :muted_ids, :text, :default => '[]'
      add_column ::Inkwell::Engine::config.community_table, :invitations_uids, :text, :default => '[]'
      add_column ::Inkwell::Engine::config.community_table, :public, :boolean, :default => true
      rename_column ::Inkwell::Engine::config.user_table, :communities_ids, :communities_info
      remove_column ::Inkwell::Engine::config.user_table, :admin_of
    end
  end
end