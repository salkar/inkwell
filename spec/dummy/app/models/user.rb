class User < ApplicationRecord
  include Inkwell::CanFavorite
  has_many :posts
  has_many :comments
end
