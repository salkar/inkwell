# frozen_string_literal: true

FactoryBot.define do
  factory :inkwell_subject_counter_cach,
          class: "Inkwell::SubjectCounterCache" do
    cached_subject_id 1
    cached_subject_type "User"
    favorite_count 1
    blog_item_count 1
    reblog_count 1
    comment_count 1
    follower_count 1
    following_count 1
  end
end
