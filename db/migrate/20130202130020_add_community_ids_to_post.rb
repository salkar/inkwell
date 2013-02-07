class AddCommunityIdsToPost < ActiveRecord::Migration
  def change
    if ::Inkwell::Engine::config.community_table
      add_column ::Inkwell::Engine::config.post_table, :communities_ids, :text, :default => '[]'
    end
  end
end