module Inkwell
  class SubjectCounterCache < ApplicationRecord
    belongs_to :cached_subject, polymorphic: true
    before_create :fill_counters

    private

    def fill_counters
      self.favorite_count =
        cached_subject.try(:inkwell_favorites).try(:count) || 0
      self.reblog_count = cached_subject.try(:inkwell_reblogs).try(:count) || 0
      self.blog_item_count =
        cached_subject.try(:inkwell_blog_items).try(:count) || 0
    end
  end
end
