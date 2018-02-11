# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples_for "can_blogging" do
  let(:owner) { create(described_class.to_s.underscore.to_sym) }
  let(:post) { create(:post) }
  let(:other_user) { create(:user) }
  let(:blog_item) do
    create(:inkwell_blog_item,
           blog_item_subject: owner,
           blog_item_object: post)
  end

  context "add_to_blog" do
    it "should be done" do
      expect(Inkwell::BlogItem.count).to eq(0)
      expect(owner.blog_items_count).to eq(0)
      expect(owner.add_to_blog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(1)
      expect(owner.blog_items_count).to eq(1)
      blog_item = Inkwell::BlogItem.first
      { blog_item_subject: owner, blog_item_object: post }.each do |k, v|
        expect(blog_item.public_send(k)).to eq(v)
      end
    end

    it "should be done when already blogged" do
      blog_item
      expect(owner.add_to_blog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(1)
    end

    it "should not be done when object is not bloggable" do
      expect { owner.add_to_blog(nil) }
        .to raise_error(Inkwell::Errors::NotBloggable)
      expect(Inkwell::BlogItem.count).to eq(0)
    end
  end

  context "remove_from_blog" do
    it "should be done" do
      blog_item
      expect(owner.blog_items_count).to eq(1)
      expect(owner.remove_from_blog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(0)
      expect(owner.reload.blog_items_count).to eq(0)
    end

    it "should be done when object is not blogged" do
      expect(owner.remove_from_blog(post)).to eq(true)
      expect(Inkwell::Favorite.count).to eq(0)
    end

    it "should not be done when object is not bloggable" do
      expect { owner.remove_from_blog(nil) }
        .to raise_error(Inkwell::Errors::NotBloggable)
      expect(Inkwell::BlogItem.count).to eq(0)
    end
  end

  context "added_to_blog?" do
    it "should be true" do
      blog_item
      expect(owner.added_to_blog?(post)).to eq(true)
    end

    it "should be false" do
      expect(owner.added_to_blog?(post)).to eq(false)
    end

    it "should not be done when object is not bloggable" do
      expect { owner.added_to_blog?(nil) }
        .to raise_error(Inkwell::Errors::NotBloggable)
    end
  end

  context "blog" do
    before :each do
      base_date = Date.yesterday
      30.times do |i|
        create(
          :inkwell_blog_item,
          blog_item_subject: owner,
          blog_item_object: create(:post),
          created_at: base_date + i.minutes)
      end
    end

    it "should work" do
      result = owner.blog do |relation|
        relation.page(1).order("created_at DESC")
      end
      expect(result.size).to eq(25)
      expect(result.map { |item| item.class.to_s }.uniq.sort)
        .to eq(%w{Post})
      expect(result.first).to eq(Inkwell::BlogItem.last.blog_item_object)
    end

    it "should work for viewer" do
      favorited = Post.last(2)
      favorited.each do |obj|
        other_user.favorite(obj)
      end
      result = owner.blog(for_viewer: other_user) do |relation|
        relation.page(1).order("created_at DESC")
      end
      expect(result.size).to eq(25)
      expect((result & favorited).size).to eq(2)
      result.each do |item|
        expect(item.favorited_in_timeline).to eq(item.in?(favorited))
      end
    end

    it "should work without block" do
      result = owner.blog
      expect(result.size).to eq(30)
    end
  end

  context "blog_items_count" do
    it "should work" do
      blog_item
      create(
        :inkwell_blog_item,
        blog_item_subject: owner,
        blog_item_object: create(:post))
      expect(owner.reload.blog_items_count).to eq(2)
    end

    it "should work without cache" do
      blog_item
      Inkwell::SubjectCounterCache.delete_all
      expect(owner.reload.blog_items_count).to eq(1)
    end
  end

  context "on destroy" do
    before :each do
      owner.add_to_blog(post)
    end

    it "should remove subject counter cache" do
      expect(owner.inkwell_subject_counter_cache.present?).to eq(true)
      owner.destroy
      expect(Inkwell::SubjectCounterCache.count).to eq(0)
    end

    it "should remove blog_items" do
      expect(owner.blog.count).to eq(1)
      owner.destroy
      expect(Inkwell::BlogItem.count).to eq(0)
    end
  end
end
