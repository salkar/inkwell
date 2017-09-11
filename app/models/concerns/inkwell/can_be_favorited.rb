module Inkwell::CanBeFavorited
  extend ActiveSupport::Concern

  included do
    attr_accessor :favorited_in_timeline
    has_one :inkwell_object_counter_cache,
             as: :cached_object,
             class_name: 'Inkwell::ObjectCounterCache'

    def favorite_count
      inkwell_object_counter_cache.try(:favorite_count) || 0
    end
  end

  module ClassMethods
    def inkwell_favoritable?
      true
    end
  end
end
