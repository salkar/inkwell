# This migration comes from inkwell (originally 20130212130888)
class RefactorFollowingsRelation < ActiveRecord::Migration
  def change
    create_table :inkwell_followings do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_column ::Inkwell::Engine::config.user_table, :follower_count, :integer, :default => 0
    add_column ::Inkwell::Engine::config.user_table, :following_count, :integer, :default => 0

    user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
    user_class.all.each do |user|
      followings_ids = ActiveSupport::JSON.decode user.followings_ids
      followers_ids = ActiveSupport::JSON.decode user.followers_ids
      user.following_count = followings_ids.size
      user.follower_count = followers_ids.size
      user.save
      followings_ids.each do |followed_id|
        ::Inkwell::Following.create :follower_id => user.id, :followed_id => followed_id
      end
    end

    remove_column ::Inkwell::Engine::config.user_table, :followers_ids
    remove_column ::Inkwell::Engine::config.user_table, :followings_ids
  end
end