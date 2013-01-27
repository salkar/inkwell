require "spec_helper"

describe "Following" do

  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.comments.create :post_id => @salkar_post.id, :body => "salkar_comment_body"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body"
    @morozovm_post = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post2 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post3 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_comment = @morozovm.comments.create :post_id => @salkar_post.id, :body => "salkar_comment_body"
  end

  it "user should follow another user" do
    @salkar.follow @morozovm
    @salkar.reload
    @morozovm.reload
    @salkar.followings_ids.should == "[#{@morozovm.id}]"
    @salkar.followings_row.should == [@morozovm.id]
    @salkar.followers_ids.should == "[]"
    @salkar.followers_row.should == []

    @salkar.timeline_items.size.should == 4
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post.id, false).should be
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post1.id, false).should be
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post2.id, false).should be
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post3.id, false).should be
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_comment.id, true).should == nil
    @salkar.timeline_items.each do |item|
      item.has_many_sources.should == false
      ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @morozovm.id, 'type' => 'following']]
    end

    @morozovm.timeline_items.size.should == 0
    @morozovm.followers_ids.should == "[#{@salkar.id}]"
    @morozovm.followers_row.should == [@salkar.id]
    @morozovm.followings_ids.should == "[]"
    @morozovm.followings_row.should == []
  end

  it "created_at from blog_item should transferred to timeline_item for follower when he follow this user" do
    @salkar.follow @morozovm
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post.id, false).created_at.to_s.should == @morozovm_post.created_at.to_s
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post1.id, false).created_at.to_s.should == @morozovm_post1.created_at.to_s
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post2.id, false).created_at.to_s.should == @morozovm_post2.created_at.to_s
    @salkar.timeline_items.find_by_item_id_and_is_comment(@morozovm_post3.id, false).created_at.to_s.should == @morozovm_post3.created_at.to_s
  end

  it "user should follow another user (follow?)" do
    @salkar.follow?(@morozovm).should == false
    @salkar.follow @morozovm
    @salkar.reload
    @morozovm.reload
    @salkar.follow?(@morozovm).should be
    @morozovm.follow?(@salkar).should == false
    @salkar.follow @morozovm
    @salkar.follow?(@morozovm).should be
  end

  it "user should not follow himself" do
    expect{@salkar.follow @salkar}.to raise_error
  end

  it "user should unfollow another user" do
    @salkar.follow @morozovm
    @salkar.reload
    @salkar.timeline_items.size.should == 4
    @salkar.unfollow @morozovm
    @salkar.reload
    @salkar.timeline_items.size.should == 0

  end

  it "reblog should added to followers timeline when follow" do
    @talisman = User.create :nick => "Talisman"
    @talisman.reblog @salkar_post
    @morozovm.follow @talisman
    @morozovm.timeline_items.size.should == 1
    item = @morozovm.timeline_items.first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'}])
    item.item_id.should == @salkar_post.id
    item.is_comment.should == false
  end

  it "timeline item should not delete if has many sources when unfollow" do
    @talisman = User.create :nick => "Talisman"
    @talisman.reblog @salkar_post
    @morozovm.follow @talisman
    @morozovm.follow @salkar
    @morozovm.timeline_items.where(:item_id => @salkar_post, :is_comment => false).size.should == 1
    item = @morozovm.timeline_items.where(:item_id => @salkar_post, :is_comment => false).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'},{'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == true

    @morozovm.unfollow @salkar
    @morozovm.timeline_items.where(:item_id => @salkar_post, :is_comment => false).size.should == 1
    item = @morozovm.timeline_items.where(:item_id => @salkar_post, :is_comment => false).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'}])
    item.has_many_sources.should == false

    @morozovm.follow @salkar
    item = @morozovm.timeline_items.where(:item_id => @salkar_post, :is_comment => false).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'},{'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == true

    @morozovm.unfollow @talisman
    @morozovm.timeline_items.where(:item_id => @salkar_post, :is_comment => false).size.should == 1
    item = @morozovm.timeline_items.where(:item_id => @salkar_post, :is_comment => false).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == false
  end


end