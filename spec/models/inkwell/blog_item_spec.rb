require 'rails_helper'

module Inkwell
  RSpec.describe BlogItem, type: :model do
    let(:post){create(:post)}
    let(:user){create(:user)}

    context 'cached objects' do
      let(:blog_item){create(:inkwell_blog_item, blog_item_subject: user, blog_item_object: post, reblog: true)}

      context 'for reblog' do
        context 'on create' do
          it 'should be created' do
            expect(post.inkwell_object_counter_cache).to eq(nil)
            expect(user.inkwell_subject_counter_cache).to eq(nil)
            blog_item
            object_cache = post.reload.inkwell_object_counter_cache
            expect(object_cache.reblog_count).to eq(1)
            subject_cache = user.reload.inkwell_subject_counter_cache
            expect(subject_cache.reblog_count).to eq(1)
            expect(subject_cache.blog_item_count).to eq(1)
          end

          it 'should update counter' do
            object_cache = post.create_inkwell_object_counter_cache!
            subject_cache = user.create_inkwell_subject_counter_cache!
            blog_item
            expect(object_cache.reload.reblog_count).to eq(1)
            expect(subject_cache.reload.reblog_count).to eq(1)
            expect(subject_cache.blog_item_count).to eq(1)
          end
        end

        context 'on destroy' do
          it 'should be created' do
            blog_item
            Inkwell::SubjectCounterCache.delete_all
            Inkwell::ObjectCounterCache.delete_all
            expect(post.reload.inkwell_object_counter_cache).to eq(nil)
            expect(user.reload.inkwell_subject_counter_cache).to eq(nil)
            blog_item.destroy
            object_cache = post.reload.inkwell_object_counter_cache
            expect(object_cache.reblog_count).to eq(0)
            subject_cache = user.reload.inkwell_subject_counter_cache
            expect(subject_cache.reblog_count).to eq(0)
            expect(subject_cache.blog_item_count).to eq(0)
          end

          it 'should update counter' do
            object_cache = post.create_inkwell_object_counter_cache!
            subject_cache = user.create_inkwell_subject_counter_cache!
            blog_item
            object_cache.update_attributes(reblog_count: 15)
            subject_cache.update_attributes(blog_item_count: 10, reblog_count: 15)
            blog_item.destroy
            expect(object_cache.reload.reblog_count).to eq(14)
            expect(subject_cache.reload.blog_item_count).to eq(9)
            expect(subject_cache.reload.reblog_count).to eq(14)
          end
        end
      end

    end
  end
end
