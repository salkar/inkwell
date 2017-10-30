class Comment < ApplicationRecord
  include Inkwell::CanBeFavorited
  include Inkwell::CanBeReblogged

  belongs_to :post, optional: true
  belongs_to :user, optional: true
end
