# frozen_string_literal: true

FactoryBot.define do
  factory :inkwell_favorite, class: "Inkwell::Favorite" do
    favorite_subject_id 1
    favorite_subject_type "User"
    favorite_object_id 1
    favorite_object_type "Post"
  end
end
