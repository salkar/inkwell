module Inkwell
  class ObjectCounterCache < ApplicationRecord
    belongs_to :cached_object, polymorphic: true
  end
end
