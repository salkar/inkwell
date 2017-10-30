class Community < ApplicationRecord
  include Inkwell::CanFavorite
  include Inkwell::CanBlogging
  include Inkwell::CanReblog
end
