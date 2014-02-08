require "spec_helper"

describe "Reblog" do

  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @talisman = User.create :nick => "Talisman"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.create_comment :for_object => @salkar_post, :body => "salkar_comment_body"
  end

  it "user should reblog post" do
    @morozovm.reblog @salkar_post
    ::Inkwell::BlogItem.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 2
    ::Inkwell::BlogItem.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER, :is_reblog => true).size.should == 1
    @salkar_post.reload
    @salkar_post.reblog_count.should == 1
  end

  it "user should reblog comment" do
    @morozovm.reblog @salkar_comment
    ::Inkwell::BlogItem.where(:item_id => @salkar_comment.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER, :is_reblog => true).size.should == 1
    @salkar_comment.reload
    @salkar_comment.reblog_count.should == 1
  end

  it "timeline item should been created for followers when user reblog post" do
    @talisman.follow @morozovm
    @morozovm.reblog @salkar_post
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    item.item_id.should == @salkar_post.id
    item.created_at.to_i.should == @salkar_post.created_at.to_i
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @morozovm.id, 'type' => 'reblog'}])
    item.item_type.should == ::Inkwell::Constants::ItemTypes::POST
  end

  it "timeline item should been created for followers when user reblog comment" do
    @talisman.follow @morozovm
    @morozovm.reblog @salkar_comment
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    item.item_id.should == @salkar_comment.id
    item.created_at.to_i.should == @salkar_comment.created_at.to_i
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @morozovm.id, 'type' => 'reblog'}])
    item.item_type.should == ::Inkwell::Constants::ItemTypes::COMMENT
  end

  it "timeline item should not been created for follower's post/comment" do
    @salkar.follow @morozovm
    @morozovm.reblog @salkar_post
    @morozovm.reblog @salkar_comment
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0
  end

  it "one timeline item should created for one post with two sources" do
    @talisman.follow @morozovm
    @morozovm.reblog @salkar_post
    @talisman.follow @salkar
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    item.has_many_sources.should == true
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @morozovm.id, 'type' => 'reblog'},{'user_id' => @salkar.id, 'type' => 'following'}])
  end

  it "one timeline item should created for one post with two sources (reblog after follow)" do
    @talisman.follow @morozovm
    @talisman.follow @salkar
    @morozovm.reblog @salkar_post
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    item.has_many_sources.should == true
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @salkar.id, 'type' => 'following'}, {'user_id' => @morozovm.id, 'type' => 'reblog'}])
  end

  it "object should not been relogged" do
    expect{@salkar.reblog("String")}.to raise_error
    expect{@salkar.reblog(@salkar_post)}.to raise_error
  end

  it "object should been reblogged (reblog?)" do
    @morozovm.reblog?(@salkar_post).should == false
    @morozovm.reblog?(@salkar_comment).should == false
    @morozovm.reblog @salkar_post
    @morozovm.reblog @salkar_comment
    @morozovm.reblog?(@salkar_post).should == true
    @morozovm.reblog?(@salkar_comment).should == true
  end

  it "user should unreblog post" do
    @morozovm.reblog @salkar_post
    @morozovm.unreblog @salkar_post
    ::Inkwell::BlogItem.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    ::Inkwell::BlogItem.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER, :is_reblog => true).size.should == 0
    @salkar_post.reload
    @salkar_post.users_ids_who_reblog_it.should == "[]"
  end

  it "user should unreblog comment" do
    @morozovm.reblog @salkar_comment
    @morozovm.unreblog @salkar_comment
    ::Inkwell::BlogItem.where(:item_id => @salkar_comment.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER, :is_reblog => true).size.should == 0
    @salkar_comment.reload
    @salkar_comment.reblog_count.should == 0
  end

  it "timeline items should delete for followers when user unreblog post" do
    @talisman = User.create :nick => "Talisman"
    @talisman.follow @morozovm
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm.reblog @salkar_post

    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 2
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.has_many_sources.should == false
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @morozovm.id, 'type' => 'reblog'}])

    @morozovm.unreblog @salkar_post
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
  end

  it "timeline items should delete for followers when user unreblog comment" do
    @talisman = User.create :nick => "Talisman"
    @talisman.follow @morozovm
    @morozovm.reblog @salkar_comment

    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_comment, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    item.has_many_sources.should == false
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @morozovm.id, 'type' => 'reblog'}])

    @morozovm.unreblog @salkar_comment
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_comment, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT).size.should == 0
  end

  it "timeline item should not been delete if post has many sources and unreblogged by following" do
    @talisman = User.create :nick => "Talisman"
    @talisman.reblog @salkar_post
    @morozovm.follow @talisman
    @morozovm.follow @salkar
    @talisman_post = @talisman.posts.create :body => "talisman_post_test_body"
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size == 2
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @talisman.id, 'type' => 'reblog'}, {'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == true

    @talisman.unreblog @salkar_post
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.from_source.should == ActiveSupport::JSON.encode([{'user_id' => @salkar.id, 'type' => 'following'}])
    item.has_many_sources.should == false
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size == 2
  end

  it "reblog count should been received for post" do
    @talisman = User.create :nick => "Talisman"
    @salkar_post.reload
    @salkar_post.reblog_count.should == 0
    @morozovm.reblog @salkar_post
    @talisman.reblog @salkar_post
    @salkar_post.reload
    @salkar_post.reblog_count.should == 2
  end

  it "reblog count should been received for post" do
    @talisman = User.create :nick => "Talisman"
    @salkar_comment.reload
    @salkar_comment.reblog_count.should == 0
    @morozovm.reblog @salkar_comment
    @talisman.reblog @salkar_comment
    @salkar_comment.reload
    @salkar_comment.reblog_count.should == 2
  end

end