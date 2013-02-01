module Inkwell
  class Engine < Rails::Engine
    config.post_table = :posts
    config.user_table = :users
  end
end