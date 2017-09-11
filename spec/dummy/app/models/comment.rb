class Comment < ApplicationRecord
  include Inkwell::CanBeFavorited

  belongs_to :post, optional: true
  belongs_to :user, optional: true
end
