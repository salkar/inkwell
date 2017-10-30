module Inkwell::CacheCountersCommon
  extend ActiveSupport::Concern

  included do
    private

    def process_object_counters(object, counters)
      counter_cache = object.inkwell_object_counter_cache
      if counter_cache.present?
        Inkwell::ObjectCounterCache.update_counters(
          counter_cache.id,
          counters)
      else
        object.create_inkwell_object_counter_cache
      end
    end

    def process_subject_counters(subject, counters)
      counter_cache = subject.inkwell_subject_counter_cache
      if counter_cache.present?
        Inkwell::SubjectCounterCache.update_counters(
          counter_cache.id,
          counters)
      else
        subject.create_inkwell_subject_counter_cache
      end
    end
  end
end
