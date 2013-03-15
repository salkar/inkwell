module Inkwell
  if ::Inkwell::Engine::config.respond_to?('community_table')
    class CommunityUser < ActiveRecord::Base
      attr_accessible "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id", "#{::Inkwell::Engine::config.community_table.to_s.singularize}_id",
                      :is_writer, :is_admin, :admin_level, :muted, :user_access, :active, :banned, :asked_invitation
      belongs_to ::Inkwell::Engine::config.community_table.to_s.singularize.to_sym
      belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize.to_sym
      belongs_to :admins, :foreign_key => "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      belongs_to :writers, :foreign_key => "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      belongs_to :muted_users, :foreign_key => "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      belongs_to :banned_users, :foreign_key => "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      belongs_to :asked_invitation_users, :foreign_key => "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
    end
  end
end