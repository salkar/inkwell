# frozen_string_literal: true

require "rails_helper"

module Inkwell
  RSpec.describe Favorite, type: :model do
    let(:post) { create(:post) }
    let(:user) { create(:user) }

    context "cached objects" do
      let(:favorite) do
        create(:inkwell_favorite,
               favorite_subject: user,
               favorite_object: post)
      end

      context "on create" do
        it "should be created" do
          expect(post.inkwell_object_counter_cache).to eq(nil)
          expect(user.inkwell_subject_counter_cache).to eq(nil)
          favorite
          object_cache = post.reload.inkwell_object_counter_cache
          expect(object_cache.favorite_count).to eq(1)
          subject_cache = user.reload.inkwell_subject_counter_cache
          expect(subject_cache.favorite_count).to eq(1)
        end

        it "should update counter" do
          object_cache = post.create_inkwell_object_counter_cache!
          subject_cache = user.create_inkwell_subject_counter_cache!
          favorite
          expect(object_cache.reload.favorite_count).to eq(1)
          expect(subject_cache.reload.favorite_count).to eq(1)
        end
      end

      context "on destroy" do
        it "should be created" do
          favorite
          Inkwell::SubjectCounterCache.delete_all
          Inkwell::ObjectCounterCache.delete_all
          expect(post.reload.inkwell_object_counter_cache).to eq(nil)
          expect(user.reload.inkwell_subject_counter_cache).to eq(nil)
          favorite.destroy
          object_cache = post.reload.inkwell_object_counter_cache
          expect(object_cache.favorite_count).to eq(0)
          subject_cache = user.reload.inkwell_subject_counter_cache
          expect(subject_cache.favorite_count).to eq(0)
        end

        it "should update counter" do
          object_cache = post.create_inkwell_object_counter_cache!
          subject_cache = user.create_inkwell_subject_counter_cache!
          favorite
          object_cache.update_attributes(favorite_count: 10)
          subject_cache.update_attributes(favorite_count: 10)
          favorite.destroy
          expect(object_cache.reload.favorite_count).to eq(9)
          expect(subject_cache.reload.favorite_count).to eq(9)
        end
      end
    end
  end
end
