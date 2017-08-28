module Inkwell
  class Favorite < ApplicationRecord
    belongs_to :favorite_subject, polymorphic: true
    belongs_to :favorite_object, polymorphic: true
  end
end
