# frozen_string_literal: true

class Post < ApplicationRecord
  include Inkwell::CanBeFavorited
  include Inkwell::CanBeBlogged
  include Inkwell::CanBeReblogged

  belongs_to :user, optional: true
  has_many :comments
end
