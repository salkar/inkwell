FactoryGirl.define do
  factory :inkwell_favorite, class: 'Inkwell::Favorite' do
    owner_id 1
    owner_type "User"
    favorited_id 1
    favorited_type "Post"
  end
end
