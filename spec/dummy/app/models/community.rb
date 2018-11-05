# frozen_string_literal: true

class Community < ApplicationRecord
  include Inkwell::CanFavorite
  include Inkwell::CanBlogging
  include Inkwell::CanReblog
end
