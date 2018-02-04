FactoryBot.define do
  factory :inkwell_blog_item, class: 'Inkwell::BlogItem' do
    blog_item_subject_id 1
    blog_item_subject_type "User"
    blog_item_object_id 1
    blog_item_object_type "Post"
    reblog false
  end
end
