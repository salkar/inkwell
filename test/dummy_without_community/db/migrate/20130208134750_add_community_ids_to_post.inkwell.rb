# This migration comes from inkwell (originally 20130202130020)
class AddCommunityIdsToPost < ActiveRecord::Migration
  def change
    if ::Inkwell::Engine::config.respond_to?('community_table')
      add_column ::Inkwell::Engine::config.post_table, :communities_ids, :text, :default => '[]'
    end
  end
end