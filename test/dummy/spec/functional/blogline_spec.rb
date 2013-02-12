require "spec_helper"

describe "BlogLine" do

  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
  end

  it "blogitem record should been created for new post" do
    ::Inkwell::BlogItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::BlogItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    item.owner_id.should == @salkar.id
    item.owner_type.should == ::Inkwell::Constants::OwnerTypes::USER
    item.item_id.should == @salkar_post.id
    item.is_reblog.should == false
    item.item_type.should == ::Inkwell::Constants::ItemTypes::POST
  end

  it "timeline items should been created for followers for new post" do
    @talisman = User.create :nick => "Talisman"
    @morozovm.follow @salkar
    @talisman.follow @salkar
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body"
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER, :item_type => ::Inkwell::Constants::ItemTypes::POST, :item_id => @salkar_post1.id).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER, :item_type => ::Inkwell::Constants::ItemTypes::POST, :item_id => @salkar_post1.id).size.should == 1
  end

  it "user should have blogline with reblogs and his posts" do
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body_1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body_2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body_3"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body_4"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body_5"
    @salkar.reblog @morozovm_post
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body_1"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body_6"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body_7"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body_8"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body_2"
    @salkar_post9 = @salkar.posts.create :body => "salkar_post_test_body_9"
    @morozovm_post3 = @morozovm.posts.create :body => "morozovm_post_test_body_3"
    @salkar.reblog @morozovm_post1
    @salkar.reblog @morozovm_post2

    @morozovm.reblog @salkar_post9
    @morozovm.favorite @salkar_post9

    bline = @salkar.blogline :for_user => @morozovm
    bline.size.should == 10
    bline[0].should == @morozovm_post2
    bline[0].is_reblog_in_blogline.should == true
    bline[1].should == @morozovm_post1
    bline[1].is_reblog_in_blogline.should == true
    bline[2].should == @salkar_post9
    bline[2].is_reblogged.should == true
    bline[2].is_favorited.should == true
    bline[2].is_reblog_in_blogline.should == false
    bline[2].item_id_in_line.should == ::Inkwell::BlogItem.where(:item_id => @salkar_post9.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.id
    bline[3].should == @salkar_post8
    bline[4].should == @salkar_post7
    bline[5].should == @salkar_post6
    bline[6].should == @morozovm_post
    bline[6].is_reblog_in_blogline.should == true
    bline[7].should == @salkar_post5
    bline[8].should == @salkar_post4
    bline[9].should == @salkar_post3
  end
end