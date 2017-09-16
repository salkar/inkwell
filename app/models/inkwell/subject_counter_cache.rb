module Inkwell
  class SubjectCounterCache < ApplicationRecord
    belongs_to :cached_subject, polymorphic: true
    before_create :fill_counters

    def rebuild_counters!
      fill_counters
      save
    end

    private

    def fill_counters
      self.favorite_count =
        cached_subject.try(:inkwell_favorites).try(:count) || 0
    end
  end
end
