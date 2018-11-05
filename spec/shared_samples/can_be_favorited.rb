# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples_for "can_be_favorited" do
  let(:user) { create(:user) }
  let(:obj) { create(described_class.to_s.underscore.to_sym) }

  context "favorited_by" do
    before :each do
      base_date = Date.yesterday
      30.times do |i|
        create(
          :inkwell_favorite,
          favorite_subject: create(%i{user community}.sample),
          favorite_object: obj,
          created_at: base_date + i.minutes)
      end
    end

    it "should work" do
      result = obj.favorited_by do |relation|
        relation.page(1).order("created_at DESC")
      end
      expect(result.size).to eq(25)
      expect(result.map(&:favorites_count).uniq).to eq([1])
      expect(result.map { |item| item.class.to_s }.uniq.sort)
        .to eq(%w{Community User})
      expect(result.first).to eq(Inkwell::Favorite.last.favorite_subject)
    end

    it "should work without block" do
      result = obj.favorited_by
      expect(result.size).to eq(30)
    end
  end

  context "favorited_by?" do
    it "should be true" do
      create(:inkwell_favorite, favorite_subject: user, favorite_object: obj)
      expect(obj.favorited_by?(user)).to eq(true)
    end

    it "should be false" do
      expect(obj.favorited_by?(user)).to eq(false)
    end

    it "should not be done when object is not favoritable" do
      expect { obj.favorited_by?(nil) }
        .to raise_error(Inkwell::Errors::CannotFavorite)
    end
  end

  context "favorited_count" do
    it "should work" do
      create(:inkwell_favorite, favorite_subject: user, favorite_object: obj)
      create(
        :inkwell_favorite,
        favorite_subject: create(:user),
        favorite_object: obj)
      expect(obj.reload.favorited_count).to eq(2)
    end

    it "should work without cache" do
      create(:inkwell_favorite, favorite_subject: user, favorite_object: obj)
      Inkwell::ObjectCounterCache.delete_all
      expect(obj.reload.favorited_count).to eq(1)
    end
  end

  context "on destroy" do
    before :each do
      user.favorite(obj)
    end

    it "should remove obj counter cache" do
      expect(obj.inkwell_object_counter_cache.present?).to eq(true)
      obj.destroy
      expect(Inkwell::ObjectCounterCache.count).to eq(0)
    end

    it "should remove favorites" do
      expect(obj.favorited_by.count).to eq(1)
      obj.destroy
      expect(Inkwell::Favorite.count).to eq(0)
    end

    it "should correctly process favoriting subject counters" do
      other_user = create(:user)
      other_user.favorite(obj)
      subject_counter = user.inkwell_subject_counter_cache
      subject_counter_1 = other_user.inkwell_subject_counter_cache
      expect(subject_counter.favorite_count).to eq(1)
      expect(subject_counter_1.favorite_count).to eq(1)
      obj.destroy
      expect(subject_counter.reload.favorite_count).to eq(0)
      expect(subject_counter_1.reload.favorite_count).to eq(0)
    end
  end
end
