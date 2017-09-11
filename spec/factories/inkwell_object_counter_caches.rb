FactoryGirl.define do
  factory :inkwell_object_counter_cache, class: 'Inkwell::ObjectCounterCache' do
    cached_object_id 1
    cached_object_type 'Post'
  end
end
