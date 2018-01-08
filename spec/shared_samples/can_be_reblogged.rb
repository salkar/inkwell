require 'rails_helper'

RSpec.shared_examples_for 'can_be_reblogged' do
  let(:user){create(:user)}
  let(:obj){create(described_class.to_s.underscore.to_sym)}
  let(:reblog){create(:inkwell_blog_item, blog_item_subject: user, blog_item_object: obj, reblog: true)}

  context 'reblogged_by' do
    before :each do
      base_date = Date.yesterday
      30.times do |i|
        create(
          :inkwell_blog_item,
          blog_item_subject: create(%i{user community}.sample),
          blog_item_object: obj,
          created_at: base_date + i.minutes,
          reblog: true)
      end
    end

    it 'should work' do
      result = obj.reblogged_by do |relation|
        relation.page(1).order('created_at DESC')
      end
      expect(result.size).to eq(25)
      expect(result.map(&:reblogs_count).uniq).to eq([1])
      expect(result.map{|item| item.class.to_s}.uniq.sort)
        .to eq(%w{Community User})
      expect(result.first).to eq(Inkwell::BlogItem.last.blog_item_subject)
    end

    it 'should work without block' do
      result = obj.reblogged_by
      expect(result.size).to eq(30)
    end
  end

  context 'reblogged_by?' do
    it 'should be true' do
      reblog
      expect(obj.reblogged_by?(user)).to eq(true)
    end

    it 'should be false' do
      expect(obj.reblogged_by?(user)).to eq(false)
    end

    it 'should not be done when object is not rebloggable' do
      expect{obj.reblogged_by?(nil)}
        .to raise_error(Inkwell::Errors::CannotReblog)
    end
  end

  context 'reblogged_count' do
    it 'should work' do
      reblog
      create(
        :inkwell_blog_item,
        blog_item_subject: create(:user),
        blog_item_object: obj,
        reblog: true)
      expect(obj.reload.reblogged_count).to eq(2)
    end

    it 'should work without cache' do
      reblog
      Inkwell::ObjectCounterCache.delete_all
      expect(obj.reload.reblogged_count).to eq(1)
    end
  end

  context 'on destroy' do
    before :each do
      user.reblog(obj)
    end

    it 'should remove obj counter cache' do
      expect(obj.inkwell_object_counter_cache.present?).to eq(true)
      obj.destroy
      expect(Inkwell::ObjectCounterCache.count).to eq(0)
    end

    it 'should remove reblogs' do
      expect(obj.reblogged_by.count).to eq(1)
      obj.destroy
      expect(Inkwell::BlogItem.count).to eq(0)
    end

    it 'should correctly process reblogging subject counters' do
      other_user = create(:user)
      other_user.reblog(obj)
      subject_counter = user.inkwell_subject_counter_cache
      subject_counter_1 = other_user.inkwell_subject_counter_cache
      expect(subject_counter.reblog_count).to eq(1)
      expect(subject_counter_1.reblog_count).to eq(1)
      obj.destroy
      expect(subject_counter.reload.reblog_count).to eq(0)
      expect(subject_counter_1.reload.reblog_count).to eq(0)
    end
  end
end
