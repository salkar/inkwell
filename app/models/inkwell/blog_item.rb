module Inkwell
  class BlogItem < ApplicationRecord
    include Inkwell::CacheCountersCommon

    belongs_to :blog_item_subject, polymorphic: true
    belongs_to :blog_item_object, polymorphic: true

    after_create :inkwell_after_create
    after_destroy :inkwell_after_destroy

    validates :blog_item_subject, presence: true
    validates :blog_item_object, presence: true

    private

    def inkwell_after_create
      subject_counters = {blog_item_count: 1}
      subject_counters[:reblog_count] = 1 if reblog
      process_subject_counters(blog_item_subject, subject_counters)
      process_object_counters(blog_item_object, reblog_count: 1) if reblog
    end

    def inkwell_after_destroy
      subject_counters = {blog_item_count: -1}
      subject_counters[:reblog_count] = -1 if reblog
      process_subject_counters(blog_item_subject, subject_counters)
      process_object_counters(blog_item_object, reblog_count: -1) if reblog
    end
  end
end
