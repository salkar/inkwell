module Inkwell
  class Following < ActiveRecord::Base
    user_class = ::Inkwell::Engine::config.user_table.to_s.singularize.capitalize
    belongs_to :following, :foreign_key => :followed_id, class_name: user_class
    belongs_to :follower, :foreign_key => :follower_id, class_name: user_class
  end
end
