module Inkwell
  class Engine < Rails::Engine
    config.post_table = :posts
    config.user_table = :users
    config.community_table = :communities
  end
end