class Post < ApplicationRecord
  include Inkwell::CanBeFavorited

  belongs_to :user, optional: true
  has_many :comments
end
