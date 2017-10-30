class User < ApplicationRecord
  include Inkwell::CanFavorite
  include Inkwell::CanBlogging
  include Inkwell::CanReblog

  has_many :posts
  has_many :comments
end
