require 'rails_helper'

RSpec.shared_examples_for 'can_reblog' do
  let(:owner){create(described_class.to_s.underscore.to_sym)}
  let(:post){create(:post)}
  let(:other_user){create(:user)}
  let(:reblog){create(:inkwell_blog_item, blog_item_subject: owner, blog_item_object: post, reblog: true)}

  context 'reblog' do
    it 'should be done' do
      expect(Inkwell::BlogItem.count).to eq(0)
      expect(post.reblogged_count).to eq(0)
      expect(owner.reblogs_count).to eq(0)
      expect(owner.reblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(1)
      expect(post.reblogged_count).to eq(1)
      expect(owner.reblogs_count).to eq(1)
      blog_item = Inkwell::BlogItem.first
      {blog_item_subject: owner,
       blog_item_object: post,
       reblog: true}.each do |k, v|
        expect(blog_item.public_send(k)).to eq(v)
      end
    end

    it 'should be done when already favorited' do
      reblog
      expect(owner.reblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(1)
    end

    it 'should not be done when object is not rebloggable' do
      expect{owner.reblog(nil)}
        .to raise_error(Inkwell::Errors::NotRebloggable)
      expect(Inkwell::BlogItem.count).to eq(0)
    end
  end

  context 'unreblog' do
    it 'should be done' do
      reblog
      expect(post.reblogged_count).to eq(1)
      expect(owner.reblogs_count).to eq(1)
      expect(owner.unreblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(0)
      expect(owner.reload.reblogs_count).to eq(0)
      expect(post.reload.reblogged_count).to eq(0)
    end

    it 'should be done when object is not favorited' do
      expect(owner.unreblog(post)).to eq(true)
      expect(Inkwell::BlogItem.count).to eq(0)
    end

    it 'should not be done when object is not rebloggable' do
      expect{owner.unreblog(nil)}
        .to raise_error(Inkwell::Errors::NotRebloggable)
      expect(Inkwell::BlogItem.count).to eq(0)
    end
  end

  context 'reblog?' do
    it 'should be true' do
      reblog
      expect(owner.reblog?(post)).to eq(true)
    end

    it 'should be false' do
      expect(owner.reblog?(post)).to eq(false)
    end

    it 'should not be done when object is not rebloggable' do
      expect{owner.reblog?(nil)}
        .to raise_error(Inkwell::Errors::NotRebloggable)
    end
  end

  context 'reblogs' do
    before :each do
      base_date = Date.yesterday
      30.times do |i|
        create(
          :inkwell_blog_item,
          blog_item_subject: owner,
          blog_item_object: create(%i{post comment}.sample),
          created_at: base_date + i.minutes,
          reblog: true)
      end
    end

    it 'should work' do
      result = owner.reblogs do |relation|
        relation.page(1).order('created_at DESC')
      end
      expect(result.size).to eq(25)
      expect(result.map(&:reblogged_count).uniq).to eq([1])
      expect(result.map{|item| item.class.to_s}.uniq.sort)
        .to eq(%w{Comment Post})
      expect(result.first).to eq(Inkwell::BlogItem.last.blog_item_object)
    end

    it 'should work for viewer' do
      reblogged = [Post.last(2).first, Comment.last(2).first]
      reblogged.each do |obj|
        other_user.reblog(obj)
      end
      result = owner.reblogs(for_viewer: other_user) do |relation|
        relation.page(1).order('created_at DESC')
      end
      expect(result.size).to eq(25)
      expect((result & reblogged).size).to eq(2)
      result.each do |item|
        expect(item.reblogged_in_timeline).to eq(item.in?(reblogged))
      end
    end

    it 'should work without block' do
      result = owner.reblogs
      expect(result.size).to eq(30)
    end
  end

  context 'reblogs_count' do
    it 'should work' do
      reblog
      create(
        :inkwell_blog_item,
        blog_item_subject: owner,
        blog_item_object: create(:post),
        reblog: true)
      expect(owner.reload.reblogs_count).to eq(2)
    end

    it 'should work without cache' do
      reblog
      Inkwell::SubjectCounterCache.delete_all
      expect(owner.reload.reblogs_count).to eq(1)
    end
  end

  context 'on destroy' do
    before :each do
      owner.reblog(post)
    end

    it 'should remove subject counter cache' do
      expect(owner.inkwell_subject_counter_cache.present?).to eq(true)
      owner.destroy
      expect(Inkwell::SubjectCounterCache.count).to eq(0)
    end

    it 'should remove favorites' do
      expect(owner.reblogs.count).to eq(1)
      owner.destroy
      expect(Inkwell::BlogItem.count).to eq(0)
    end

    it 'should correctly process reblogged object counters' do
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
