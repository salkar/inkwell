# This migration comes from inkwell (originally 20130212130898)
class RefactorUserCommunityRelation < ActiveRecord::Migration
  def change
    if ::Inkwell::Engine::config.respond_to?('community_table')
      user_id = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      community_id = "#{::Inkwell::Engine::config.community_table.to_s.singularize}_id"

      create_table :inkwell_community_users do |t|
        t.integer user_id
        t.integer community_id
        t.string :user_access, :default => "r"
        t.boolean :is_admin, :default => false
        t.integer :admin_level
        t.boolean :muted, :default => false

        t.timestamps
      end

      add_column ::Inkwell::Engine::config.community_table, :user_count, :integer, :default => 0
      add_column ::Inkwell::Engine::config.community_table, :writer_count, :integer, :default => 0
      add_column ::Inkwell::Engine::config.community_table, :admin_count, :integer, :default => 0
      add_column ::Inkwell::Engine::config.community_table, :muted_count, :integer, :default => 0
      add_column ::Inkwell::Engine::config.user_table, :community_count, :integer, :default => 0

      community_class = Object.const_get ::Inkwell::Engine::config.community_table.to_s.singularize.capitalize

      community_class.all.each do |community|
        users_ids = ActiveSupport::JSON.decode community.users_ids
        community.user_count = users_ids.size

        users_ids.each do |uid|
          ::Inkwell::CommunityUser.create user_id => uid, community_id => community.id
        end

        writers_ids = ActiveSupport::JSON.decode community.writers_ids
        community.writer_count = writers_ids.size

        writers_ids.each do |uid|
          ::Inkwell::CommunityUser.where(user_id => uid, community_id => community.id).update_all(:user_access => "w")
        end

        admins_info = ActiveSupport::JSON.decode community.admins_info
        community.admin_count = admins_info.size

        admins_info.each do |rec|
          ::Inkwell::CommunityUser.where(user_id => rec['admin_id'], community_id => community.id).update_all(:is_admin => true, :admin_level => rec['admin_level'])
        end

        muted_ids = ActiveSupport::JSON.decode community.muted_ids
        community.muted_count = muted_ids.size

        muted_ids.each do |uid|
          ::Inkwell::CommunityUser.where(user_id => uid, community_id => community.id).update_all(:muted => true)
        end

        community.save
      end

      user_class = Object.const_get ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
      user_class.all.each do |user|
        communities_info = ActiveSupport::JSON.decode user.communities_info
        user.community_count = communities_info.size
        user.save
      end

      remove_column ::Inkwell::Engine::config.community_table, :users_ids
      remove_column ::Inkwell::Engine::config.community_table, :writers_ids
      remove_column ::Inkwell::Engine::config.community_table, :admins_info
      remove_column ::Inkwell::Engine::config.community_table, :muted_ids
      remove_column ::Inkwell::Engine::config.user_table, :communities_info
    end
  end
end