# This migration comes from inkwell (originally 20121209124743)
class CreateInkwellComments < ActiveRecord::Migration
  def change
    create_table :inkwell_comments do |t|
      t.integer "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      t.text :body
      t.integer :parent_id
      t.integer "#{::Inkwell::Engine::config.post_table.to_s.singularize}_id"
      t.text :upper_comments_tree
      t.text     :users_ids_who_favorite_it
      t.text     :users_ids_who_comment_it
      t.text     :users_ids_who_reblog_it

      t.timestamps
    end
  end
end
