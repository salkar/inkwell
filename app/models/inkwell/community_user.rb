module Inkwell
  if ::Inkwell::Engine::config.respond_to?('community_table')
    class CommunityUser < ActiveRecord::Base
      attr_accessible "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id", "#{::Inkwell::Engine::config.community_table.to_s.singularize}_id",
                      :is_writer, :is_admin, :admin_level, :muted, :user_access, :active, :banned, :asked_invitation
    end
  end
end