# This migration comes from inkwell (originally 20130212130908)
class RefactorInvitesBansMutes < ActiveRecord::Migration
  def change
    if ::Inkwell::Engine::config.respond_to?('community_table')
      user_id = "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      community_id = "#{::Inkwell::Engine::config.community_table.to_s.singularize}_id"

      add_column ::Inkwell::Engine::config.community_table, :banned_count, :integer, :default => 0
      add_column ::Inkwell::Engine::config.community_table, :invitation_count, :integer, :default => 0

      change_column ::Inkwell::Engine::config.community_table, :user_count, :integer, :default => 1
      change_column ::Inkwell::Engine::config.community_table, :admin_count, :integer, :default => 1
      change_column ::Inkwell::Engine::config.community_table, :writer_count, :integer, :default => 1

      add_column :inkwell_community_users, :active, :boolean, :default => false
      add_column :inkwell_community_users, :banned, :boolean, :default => false
      add_column :inkwell_community_users, :asked_invitation, :boolean, :default => false

      community_class = Object.const_get ::Inkwell::Engine::config.community_table.to_s.singularize.capitalize

      community_class.all.each do |community|
        banned_ids = ActiveSupport::JSON.decode community.banned_ids
        community.banned_count = banned_ids.size
        banned_ids.each do |uid|
          relations = ::Inkwell::CommunityUser.where community_id => community.id, user_id => uid
          if relations.empty?
            ::Inkwell::CommunityUser.create community_id => community.id, user_id => uid, :active => false, :banned => true
          else
            relation = relations.first
            relation.active = false
            relation.banned = true
            relation.save
          end
        end

        invitations_uids = ActiveSupport::JSON.decode community.invitations_uids
        community.invitation_count = invitations_uids.size
        invitations_uids.each do |uid|
          ::Inkwell::CommunityUser.create community_id => community.id, user_id => uid, :active => false, :asked_invitation => true
        end

        community.save
      end

      remove_column ::Inkwell::Engine::config.community_table, :banned_ids
      remove_column ::Inkwell::Engine::config.community_table, :invitations_uids
    end
  end
end