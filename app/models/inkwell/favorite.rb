module Inkwell
  class Favorite < ApplicationRecord
    belongs_to :favorite_subject, polymorphic: true
    belongs_to :favorite_object, polymorphic: true

    after_create :process_counters_on_create
    after_destroy :process_counters_on_destroy

    validates :favorite_subject, presence: true
    validates :favorite_object, presence: true

    private

    # TODO refactor later

    def process_counters_on_create
      process_object_counters(:favorite_count, 1)
      process_subject_counters(:favorite_count, 1)
    end

    def process_counters_on_destroy
      process_object_counters(:favorite_count, -1)
      process_subject_counters(:favorite_count, -1)
    end

    def process_object_counters(counter, value)
      counter_cache = favorite_object.inkwell_object_counter_cache
      if counter_cache.present?
        Inkwell::ObjectCounterCache.update_counters(
          counter_cache.id,
          counter => value)
      else
        favorite_object.create_inkwell_object_counter_cache
      end
    end

    def process_subject_counters(counter, value)
      counter_cache = favorite_subject.inkwell_subject_counter_cache
      if counter_cache.present?
        Inkwell::SubjectCounterCache.update_counters(
          counter_cache.id,
          counter => value)
      else
        favorite_subject.create_inkwell_subject_counter_cache
      end
    end
  end
end
