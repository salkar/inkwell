# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples_for "can_be_blogged" do
  let(:user) { create(:user) }
  let(:obj) { create(described_class.to_s.underscore.to_sym) }
  let(:blog_item) { create(:inkwell_blog_item, blog_item_subject: user, blog_item_object: obj) }

  context "blogged_by" do
    it "should return object" do
      blog_item
      expect(obj.blogged_by).to eq(user)
    end

    it "should return nil" do
      expect(obj.blogged_by).to eq(nil)
    end
  end

  context "blogged_by?" do
    it "should be true" do
      blog_item
      expect(obj.blogged_by?(user)).to eq(true)
    end

    it "should be false" do
      expect(obj.blogged_by?(user)).to eq(false)
    end

    it "should not be done when object is not bloggable" do
      expect { obj.blogged_by?(nil) }
        .to raise_error(Inkwell::Errors::CannotBlogging)
    end
  end

  context "on destroy" do
    before :each do
      blog_item
    end

    it "should remove favorites" do
      expect(obj.blogged_by.present?).to eq(true)
      obj.destroy
      expect(Inkwell::BlogItem.count).to eq(0)
    end

    it "should correctly process favoriting subject counters" do
      subject_counter = user.inkwell_subject_counter_cache
      expect(subject_counter.blog_item_count).to eq(1)
      obj.destroy
      expect(subject_counter.reload.blog_item_count).to eq(0)
    end
  end
end
