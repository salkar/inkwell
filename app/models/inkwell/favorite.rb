module Inkwell
  class Favorite < ApplicationRecord
    belongs_to :favorite_subject, polymorphic: true
    belongs_to :favorite_object, polymorphic: true

    after_create :process_counters_on_create
    after_destroy :process_counters_on_destroy

    validates :favorite_subject, presence: true
    validates :favorite_object, presence: true

    private

    def process_counters_on_create
      counter_cache = favorite_object.inkwell_object_counter_cache
      if counter_cache.present?
        Inkwell::ObjectCounterCache.update_counters(
          counter_cache.id,
          favorite_count: 1)
      else
        favorite_object.create_inkwell_object_counter_cache(favorite_count: 1)
      end
    end

    def process_counters_on_destroy
      counter_cache = favorite_object.inkwell_object_counter_cache
      if counter_cache.present?
        Inkwell::ObjectCounterCache.update_counters(
          counter_cache.id,
          favorite_count: -1)
      end
    end
  end
end
