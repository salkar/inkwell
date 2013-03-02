module Inkwell
  class CommunityUser < ActiveRecord::Base
    belongs_to ::Inkwell::Engine::config.community_table.to_s.singularize.to_sym
    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize.to_sym

    attr_accessible "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id", "#{::Inkwell::Engine::config.community_table.to_s.singularize}_id",
                    :is_writer, :is_admin, :admin_level, :muted, :user_access
  end
end