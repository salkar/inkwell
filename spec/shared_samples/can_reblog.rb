# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples_for "can_reblog" do
  let(:owner) { create(described_class.to_s.underscore.to_sym) }
  let(:post) { create(:post) }
  let(:other_user) { create(:user) }
  let(:reblog) do
    create(:inkwell_blog_item,
           blog_item_subject: owner,
           blog_item_object: post,
           reblog: true)
  end

  context "reblog" do
    it "should be done" do
      expect(Inkwell::BlogItem.count).to eq(0)
      expect(post.reblogged_count).to eq(0)
      expect(owner.reblogs_count).to eq(0)
      expect(owner.reblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(1)
      expect(post.reblogged_count).to eq(1)
      expect(owner.reblogs_count).to eq(1)
      blog_item = Inkwell::BlogItem.first
      { blog_item_subject: owner,
       blog_item_object: post,
       reblog: true }.each do |k, v|
        expect(blog_item.public_send(k)).to eq(v)
      end
    end

    it "should be done when already favorited" do
      reblog
      expect(owner.reblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(1)
    end

    it "should not be done when object is not rebloggable" do
      expect { owner.reblog(nil) }
        .to raise_error(Inkwell::Errors::NotRebloggable)
      expect(Inkwell::BlogItem.count).to eq(0)
    end
  end

  context "unreblog" do
    it "should be done" do
      reblog
      expect(post.reblogged_count).to eq(1)
      expect(owner.reblogs_count).to eq(1)
      expect(owner.unreblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(0)
      expect(owner.reload.reblogs_count).to eq(0)
      expect(post.reload.reblogged_count).to eq(0)
    end

    it "should be done when object is not favorited" do
      expect(owner.unreblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(0)
    end

    it "should not be done when object is not rebloggable" do
      expect { owner.unreblog(nil) }
        .to raise_error(Inkwell::Errors::NotRebloggable)
      expect(Inkwell::BlogItem.count).to eq(0)
    end
  end

  context "reblog?" do
    it "should be true" do
      reblog
      expect(owner.reblog?(post)).to eq(true)
    end

    it "should be false" do
      expect(owner.reblog?(post)).to eq(false)
    end

    it "should not be done when object is not rebloggable" do
      expect { owner.reblog?(nil) }
        .to raise_error(Inkwell::Errors::NotRebloggable)
    end
  end

  context "blog with reblog feature" do
    before :each do
      base_date = Date.yesterday
      30.times do |i|
        create(
          :inkwell_blog_item,
          blog_item_subject: owner,
          blog_item_object: create(%i{post comment}.sample),
          created_at: base_date + i.minutes,
          reblog: i.in?([28, 29]))
      end
    end

    it "should work" do
      result = owner.blog do |relation|
        relation.page(1).order("created_at DESC")
      end
      expect(result.size).to eq(25)
      expect(result.map { |item| item.class.to_s }.uniq.sort)
        .to eq(%w{Comment Post})
      expect(result.first).to eq(Inkwell::BlogItem.last.blog_item_object)
      result.first(2).each do |reblog|
        expect(reblog.reblogged_count).to eq(1)
        expect(reblog.reblog_in_timeline).to eq(true)
      end
      result.last(23).each do |reblog|
        expect(reblog.reblogged_count).to eq(0)
        expect(reblog.reblog_in_timeline).to eq(false)
      end
    end

    it "should work for viewer" do
      reblogged_by_viewer =
        Inkwell::BlogItem.where(reblog: true).last.blog_item_object
      other_user.reblog(reblogged_by_viewer)
      result = owner.reblogs(for_viewer: other_user) do |relation|
        relation.page(1).order("created_at DESC")
      end
      expect(result.size).to eq(2)
      expect(result.include?(reblogged_by_viewer)).to eq(true)
      result.each do |item|
        expect(item.reblogged_in_timeline).to eq(item == reblogged_by_viewer)
      end
    end

    it "should work without block" do
      result = owner.reblogs
      expect(result.size).to eq(2)
    end
  end

  context "reblogs_count" do
    it "should work" do
      reblog
      create(
        :inkwell_blog_item,
        blog_item_subject: owner,
        blog_item_object: create(:post),
        reblog: true)
      expect(owner.reload.reblogs_count).to eq(2)
    end

    it "should work without cache" do
      reblog
      Inkwell::SubjectCounterCache.delete_all
      expect(owner.reload.reblogs_count).to eq(1)
    end
  end

  context "on destroy" do
    before :each do
      owner.reblog(post)
    end

    it "should remove subject counter cache" do
      expect(owner.inkwell_subject_counter_cache.present?).to eq(true)
      owner.destroy
      expect(Inkwell::SubjectCounterCache.count).to eq(0)
    end

    it "should remove favorites" do
      expect(owner.inkwell_reblogs.count).to eq(1)
      owner.destroy
      expect(Inkwell::BlogItem.count).to eq(0)
    end

    it "should correctly process reblogging object counters" do
      comment = create(:comment)
      owner.reblog(comment)
      object_counter = post.inkwell_object_counter_cache
      object_counter_1 = comment.inkwell_object_counter_cache
      expect(object_counter.reblog_count).to eq(1)
      expect(object_counter_1.reblog_count).to eq(1)
      owner.destroy
      expect(object_counter.reload.reblog_count).to eq(0)
      expect(object_counter_1.reload.reblog_count).to eq(0)
    end
  end
end
