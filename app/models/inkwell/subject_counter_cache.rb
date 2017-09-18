module Inkwell
  class SubjectCounterCache < ApplicationRecord
    belongs_to :cached_subject, polymorphic: true
    before_create :fill_counters

    private

    def fill_counters
      self.favorite_count =
        cached_subject.try(:inkwell_favorites).try(:count) || 0
    end
  end
end
