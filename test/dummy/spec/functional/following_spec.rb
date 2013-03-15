require "spec_helper"

describe "Following" do

  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @talisman = User.create :nick => "Talisman"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.create_comment :for_object => @salkar_post, :body => "salkar_comment_body"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body"
    @morozovm_post = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post2 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post3 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_comment = @morozovm.create_comment :for_object => @salkar_post, :body => "salkar_comment_body"
  end

  it "user should follow another user" do
    @salkar.follow @morozovm
    @salkar.reload
    @morozovm.reload
    @morozovm.followings_row.should == []
    @morozovm.followers_row.should == [@salkar.id]
    @morozovm.follower_count.should == 1
    @morozovm.following_count.should == 0
    @salkar.follower_count.should == 0
    @salkar.following_count.should == 1
    @salkar.followings_row.should == [@morozovm.id]
    @salkar.followers_row.should == []
    ::Inkwell::Following.exists?(:follower_id => @salkar.id, :followed_id => @morozovm.id).should == true

    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 4
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post.id, ::Inkwell::Constants::ItemTypes::POST).should be
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post1.id, ::Inkwell::Constants::ItemTypes::POST).should be
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post2.id, ::Inkwell::Constants::ItemTypes::POST).should be
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post3.id, ::Inkwell::Constants::ItemTypes::POST).should be
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_comment.id, ::Inkwell::Constants::ItemTypes::COMMENT).should == nil
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).each do |item|
      item.has_many_sources.should == false
      ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @morozovm.id, 'type' => 'following']]
    end

    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0
  end

  it "created_at from blog_item should transferred to timeline_item for follower when he follow this user" do
    @salkar.follow @morozovm
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post.id, ::Inkwell::Constants::ItemTypes::POST).created_at.to_s.should == @morozovm_post.created_at.to_s
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post1.id, ::Inkwell::Constants::ItemTypes::POST).created_at.to_s.should == @morozovm_post1.created_at.to_s
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post2.id, ::Inkwell::Constants::ItemTypes::POST).created_at.to_s.should == @morozovm_post2.created_at.to_s
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).find_by_item_id_and_item_type(@morozovm_post3.id, ::Inkwell::Constants::ItemTypes::POST).created_at.to_s.should == @morozovm_post3.created_at.to_s
  end

  it "user should follow another user (follow?)" do
    @salkar.follow?(@morozovm).should == false
    @salkar.follow @morozovm
    @salkar.reload
    @morozovm.reload
    @salkar.follow?(@morozovm).should be
    @morozovm.follow?(@salkar).should == false
  end

  it "user should not follow already followed user" do
    @salkar.follow @morozovm
    @salkar.follow?(@morozovm).should == true
    expect{@salkar.follow @morozovm}.to raise_error
  end

  it "user should not follow himself" do
    expect{@salkar.follow @salkar}.to raise_error
  end

  it "user should unfollow another user" do
    @salkar.follow @morozovm
    @salkar.reload
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 4
    @salkar.unfollow @morozovm
    @salkar.reload
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0

    @salkar.followings_row.should == []
    @salkar.followers_row.should == []
    @morozovm.followings_row.should == []
    @morozovm.followers_row.should == []
    @salkar.follower_count.should == 0
    @salkar.following_count.should == 0
    @morozovm.follower_count.should == 0
    @morozovm.following_count.should == 0
  end

  it "reblog should added to followers timeline when follow" do
    @talisman = User.create :nick => "Talisman"
    @talisman.reblog @salkar_post
    @morozovm.follow @talisman
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'}])
    item.item_id.should == @salkar_post.id
    item.item_type.should == ::Inkwell::Constants::ItemTypes::POST
  end

  it "timeline item should not delete if has many sources when unfollow" do
    @talisman = User.create :nick => "Talisman"
    @talisman.reblog @salkar_post
    @morozovm.follow @talisman
    @morozovm.follow @salkar
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'},{'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == true

    @morozovm.unfollow @salkar
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'}])
    item.has_many_sources.should == false

    @morozovm.follow @salkar
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'},{'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == true

    @morozovm.unfollow @talisman
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == false
  end

  it "self reblogs after follow should not transferred to timeline" do
    @talisman = User.create :nick => "Talisman"
    @talisman.reblog @salkar_post
    @salkar.follow @talisman
    @salkar.reload
    @salkar.timeline.size.should == 0
  end

  it "following relations should be returned for user" do
    @salkar.follow @talisman
    @salkar.follow @morozovm
    following_relations = @salkar.following_relations
    following_relations.size.should == 2
    following_relations.where(:followed_id => @talisman.id).size.should == 1
    following_relations.where(:followed_id => @morozovm.id).size.should == 1
  end

  it "follower relations should be returned for user" do
    @talisman.follow @salkar
    @morozovm.follow @salkar
    follower_relations = @salkar.follower_relations
    follower_relations.size.should == 2
    follower_relations.where(:follower_id => @talisman.id).size.should == 1
    follower_relations.where(:follower_id => @morozovm.id).size.should == 1
  end

  it "followings should be returned" do
    @salkar.follow @talisman
    @salkar.follow @morozovm
    followings = @salkar.followings
    followings.size.should == 2
    followings.include?(@talisman).should == true
    followings.include?(@morozovm).should == true
  end

  it "followers should be returned" do
    @talisman.follow @salkar
    @morozovm.follow @salkar
    followers = @salkar.followers
    followers.size.should == 2
    followers.include?(@talisman).should == true
    followers.include?(@morozovm).should == true
  end


end