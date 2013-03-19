require "spec_helper"

describe "Community" do
  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @talisman = User.create :nick => "Talisman"
    @spy = User.create :nick => "Spy"
    @community_1 = Community.create :name => "Community_1", :owner_id => @talisman.id
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar.reload
    @talisman.reload
    @morozovm.reload
    @community_1.reload
  end

  it "user should been added to community" do
    ::Inkwell::CommunityUser.where(:user_id => @talisman.id, :community_id => @community_1.id).size.should == 1
    ::Inkwell::CommunityUser.where(:user_id => @salkar.id, :community_id => @community_1.id).empty?.should == true
    @salkar.communities_row.size.should == 0
    @community_1.add_user :user => @salkar
    @community_1.reload
    @salkar.reload
    ::Inkwell::CommunityUser.where(:user_id => @salkar.id, :community_id => @community_1.id).should be
  end

  it "community's posts should been transferred to user timeline" do
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    @talisman = User.create :nick => "Talisman"
    @community_1.add_user :user => @talisman
    @talisman.reload
    tline = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER)
    tline.size.should == 10
    tline[0].item_id.should == @morozovm_post2.id
    tline[0].item_type.should == ::Inkwell::Constants::ItemTypes::POST
    ActiveSupport::JSON.decode(tline[0].from_source).should == [Hash['community_id' => @community_1.id]]
    tline[9].item_id.should == @salkar_post2.id
    tline[9].item_type.should == ::Inkwell::Constants::ItemTypes::POST
    ActiveSupport::JSON.decode(tline[9].from_source).should == [Hash['community_id' => @community_1.id]]
  end

  it "community's posts should been transferred to user timeline (if some timeline items exist)" do
    @talisman = User.create :nick => "Talisman"
    @talisman.follow @salkar
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    @community_1.add_user :user => @talisman
    @talisman.reload
    tline = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER)
    tline.size.should == 12
    item = tline.where(:item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.should be
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item = tline.where(:item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.should be
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following'], Hash['community_id' => @community_1.id]]
  end

  it "community's posts should not been transferred to user timeline (posts with authorship of user)" do
    @talisman = User.create :nick => "Talisman"
    @talisman.follow @salkar
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    @community_1.add_user :user => @salkar
    @salkar.reload
    tline = ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER)
    tline.size.should == 3
    item = tline.where(:item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.should be
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item = tline.where(:item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first
    item.should == nil
  end

  it "error should occure on tries to pass incorrect params into add_user" do
    expect { @community_1.add_user :user => "@salkar" }.to raise_error
    expect { @community_1.add_user @salkar }.to raise_error
  end

  it "user should be in community after added (include_user?)" do
    @community_1.include_user?(@salkar).should == false
    ::Inkwell::CommunityUser.create :user_id => @salkar.id, :community_id => @community_1.id, :active => true
    @community_1.include_user?(@salkar).should == true
  end

  it "user should not be admin" do
    @community_1.include_admin?(@salkar).should == false
  end

  it "user should be admin" do
    @community_1.include_admin?(@talisman).should == true
  end

  it "user should remove himself from community" do
    @community_1.add_user :user => @salkar
    @community_1.reload
    @salkar.reload
    @community_1.include_user?(@salkar).should be
    @community_1.remove_user :user => @salkar
    @community_1.reload
    @salkar.reload
    @community_1.include_user?(@salkar).should == false
    @community_1.admins_row.size.should == 1
  end

  it "community owner should not remove himself from community" do
    @community_1.reload
    @talisman.reload
    @community_1.include_user?(@talisman).should == true
    @community_1.include_admin?(@talisman).should == true
    @community_1.admin_level_of(@talisman).should == 0
    expect { @community_1.remove_user :admin => @talisman, :user => @talisman }.to raise_error
  end

  it "user should not be removed from community by admin with less permissions" do
    @talisman.reload
    @community_1.add_user :user => @salkar
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @salkar.reload
    expect { @community_1.remove_user :admin => @salkar, :user => @talisman }.to raise_error
    @community_1.add_user :user => @morozovm
    @community_1.add_admin :user => @morozovm, :admin => @salkar
    @morozovm.reload
    expect { @community_1.remove_user :admin => @morozovm, :user => @salkar }.to raise_error
    @korolevb = User.create :nick => "Korolevb"
    @community_1.add_user :user => @korolevb
    @community_1.add_admin :user => @korolevb, :admin => @talisman
    @korolevb.reload
    expect { @community_1.remove_user :admin => @korolevb, :user => @salkar }.to raise_error
  end

  it "community posts should be removed from timeline when user is removed from community" do
    @talisman = User.create :nick => "Talisman"
    @talisman.follow @salkar
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY
    @community_1.add_user :user => @talisman
    @talisman.reload
    @community_1.reload
    tline = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER)
    tline.size.should == 12
    @community_1.include_user?(@talisman).should == true
    @community_1.remove_user :user => @talisman
    @talisman.reload
    tline = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER)
    tline.size.should == 9
    tline.where(:item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.should == nil
    tline.where(:item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.should == nil
    tline.where(:item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.should == nil
    ActiveSupport::JSON.decode(tline.where(:item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
  end

  it "admin level of user should be returned" do
    @community_1.admin_level_of(@talisman).should == 0
  end

  it "admin level of user should not be returned" do
    expect { @community_1.admin_level_of(@salkar) }.to raise_error
  end

  it "admin should be added" do
    @community_1.add_user :user => @morozovm
    @community_1.add_admin :admin => @talisman, :user => @morozovm
    @community_1.reload
    @salkar.reload
    @community_1.include_admin?(@morozovm).should == true
    @community_1.admin_level_of(@morozovm).should == 1
  end

  it "admin should not be added" do
    expect { @community_1.add_admin(:user => @salkar) }.to raise_error
    expect { @community_1.add_admin(:user => @salkar, :admin => @talisman) }.to raise_error
    expect { @community_1.add_admin(:user => "@salkar", :admin => "@talisman") }.to raise_error

    @community_1.add_user :user => @salkar
    expect { @community_1.add_admin :admin => @salkar, :user => @salkar }.to raise_error

    @community_1.admins_row.size.should == 1
  end

  it "admin should be removed" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @salkar.reload
    @morozovm.reload
    @community_1.add_admin :admin => @salkar, :user => @morozovm
    @community_1.reload
    @morozovm.reload
    @community_1.include_admin?(@morozovm).should == true
    @community_1.remove_admin :admin => @salkar, :user => @morozovm
    @community_1.reload
    @morozovm.reload
    @community_1.include_admin?(@salkar).should == true
    @community_1.include_admin?(@morozovm).should == false
    @community_1.admins_row.size.should == 2

    @community_1.add_admin :admin => @salkar, :user => @morozovm
    @community_1.reload
    @morozovm.reload
    @community_1.include_admin?(@morozovm).should == true
    @community_1.remove_admin :admin => @morozovm, :user => @morozovm
    @community_1.reload
    @morozovm.reload
    @community_1.include_admin?(@morozovm).should == false
  end

  it "admin should not be removed" do
    expect { @community_1.remove_admin :admin => @salkar, :user => @morozovm }.to raise_error
    expect { @community_1.remove_admin :admin => "@salkar", :user => "@morozovm" }.to raise_error
    expect { @community_1.remove_admin :user => @morozovm }.to raise_error

    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_admin :user => @salkar, :admin => @talisman

    @community_1.add_admin :admin => @salkar, :user => @morozovm
    @community_1.reload
    @morozovm.reload
    expect { @community_1.remove_admin :user => @salkar, :admin => @morozovm }.to raise_error
  end

  it "after creating community owner should be added to community as an admin" do
    @community_2 = Community.create :name => "Community_2", :owner_id => @talisman.id
    @talisman.reload
    @community_2.reload
    @community_2.include_user?(@talisman).should == true
    @community_2.include_admin?(@talisman).should == true
    @community_2.admin_level_of(@talisman).should == 0
  end

  it "community should be destroyed" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    @community_1.add_post :post => @salkar_post, :user => @salkar
    @community_1.add_post :post => @salkar_post1, :user => @salkar
    @community_1.add_post :post => @salkar_post2, :user => @salkar
    @community_1.add_post :post => @salkar_post3, :user => @salkar
    @community_1.add_post :post => @salkar_post4, :user => @salkar
    @community_1.add_post :post => @salkar_post5, :user => @salkar
    @community_1.add_post :post => @salkar_post6, :user => @salkar
    @community_1.add_post :post => @salkar_post7, :user => @salkar
    @community_1.add_post :post => @salkar_post8, :user => @salkar
    @community_1.add_post :post => @morozovm_post, :user => @morozovm
    @community_1.add_post :post => @morozovm_post1, :user => @morozovm
    @community_1.add_post :post => @morozovm_post2, :user => @morozovm
    @talisman.follow @morozovm
    @salkar.follow @morozovm
    ::Inkwell::BlogItem.all.size.should == 24
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 3
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 12
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 9
    id = @community_1.id

    @community_1.reload
    @community_1.destroy
    ::Inkwell::BlogItem.all.size.should == 12
    ::Inkwell::BlogItem.where(:owner_id => id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY).size.should == 0
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 3
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 3
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).each do |item|
      item.has_many_sources.should == false
      ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @morozovm.id, 'type' => 'following']]
    end
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).each do |item|
      item.has_many_sources.should == false
      ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @morozovm.id, 'type' => 'following']]
    end
    @salkar.reload
    @talisman.reload
    @morozovm.reload
    @salkar.communities_row.size.should == 0
    @talisman.communities_row.size.should == 0
    @morozovm.communities_row.size.should == 0
  end

  it "post should be added to community blogline and user's timeline" do
    @community_1.add_user :user => @salkar
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @community_1.add_post :post => @salkar_post, :user => @salkar
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.communities_ids).should == [@community_1.id]
  end

  it "post info should be added to existing user's timeline items" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.reload
    @morozovm.reload
    @talisman.follow @salkar
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0

    @community_1.add_post :post => @salkar_post, :user => @salkar
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following'], Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == true

    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0

    @morozovm.reload
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false
  end

  it "post should not be added to community blogline and user's timeline" do
    expect { @community_1.add_post :user => @salkar, :post => @salkar_post }.to raise_error
    expect { @community_1.add_post :user => @talisman, :post => @salkar_post }.to raise_error
    expect { @community_1.add_post :user => @talisman, :post => "@salkar_post" }.to raise_error
    expect { @community_1.add_post :user => "@talisman", :post => @salkar_post }.to raise_error
    expect { @community_1.add_post :user => @talisman }.to raise_error
    expect { @community_1.add_post :post => @salkar_post }.to raise_error

    @community_1.add_user :user => @salkar
    @community_1.add_post :post => @salkar_post, :user => @salkar
    expect { @community_1.add_post :post => @salkar_post, :user => @salkar }.to raise_error
  end

  it "post should be removed by owner from community" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_post :post => @salkar_post, :user => @salkar
    @talisman.follow @salkar
    @talisman.reload
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id], Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == true
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @community_1.remove_post :post => @salkar_post, :user => @salkar
    @talisman.reload
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == false

    @morozovm.reload
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0

    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.communities_ids).size.should == 0
  end

  it "post should be removed by admin from community" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_post :post => @salkar_post, :user => @salkar
    @talisman.follow @salkar
    @talisman.reload
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id], Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == true
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @salkar.reload
    @talisman.reload
    @community_1.remove_post :post => @salkar_post, :user => @talisman
    @talisman.reload
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == false

    @morozovm.reload
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0

    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.communities_ids).size.should == 0
  end

  it "post should not be removed from community" do
    expect { @community_1.remove_post :user => @salkar, :post => @salkar_post }.to raise_error
    @community_1.add_user :user => @salkar
    expect { @community_1.remove_post :user => @salkar, :post => @salkar_post }.to raise_error
    expect { @community_1.remove_post :user => @talisman, :post => @salkar_post }.to raise_error
    @community_1.add_post :post => @salkar_post, :user => @salkar

    expect { @community_1.remove_post :user => @talisman, :post => "@salkar_post" }.to raise_error
    expect { @community_1.remove_post :user => "@talisman", :post => @salkar_post }.to raise_error
    expect { @community_1.remove_post :user => @talisman }.to raise_error
    expect { @community_1.remove_post :post => @salkar_post }.to raise_error

    @community_1.add_user :user => @morozovm
    expect { @community_1.remove_post :post => @salkar_post, :user => @morozovm }.to raise_error

    @talisman.reload
    @community_1.add_admin :admin => @talisman, :user => @salkar
    @community_1.add_admin :admin => @salkar, :user => @morozovm
    @salkar.reload
    @morozovm.reload
    expect { @community_1.remove_post :post => @salkar_post, :user => @morozovm }.to raise_error
  end

  it "user should join community" do
    @community_1.users_row.size.should == 1
    @salkar.communities_row.size.should == 0
    @salkar.join @community_1
    @community_1.reload
    @salkar.reload
    @community_1.users_row.size.should == 2
    @community_1.include_user?(@salkar).should == true
    @salkar.communities_row.should == [@community_1.id]
  end

  it "user should leave community" do
    @community_1.add_user :user => @salkar
    @community_1.reload
    @salkar.reload
    @community_1.include_user?(@salkar).should be
    @salkar.leave @community_1
    @community_1.reload
    @salkar.reload
    @community_1.include_user?(@salkar).should == false
    @community_1.include_admin?(@salkar).should == false
  end

  it "user should be kicked from community" do
    @community_1.add_user :user => @salkar
    @community_1.reload
    @salkar.reload
    @community_1.include_user?(@salkar).should be
    @talisman.reload
    @talisman.kick :user => @salkar, :from_community => @community_1
    @community_1.reload
    @salkar.reload
    @community_1.include_user?(@salkar).should == false
  end

  it "post should be sended to community" do
    @community_1.add_user :user => @salkar
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community_1
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @salkar.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.communities_ids).should == [@community_1.id]
  end

  it "post should be removed from community" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_post :post => @salkar_post, :user => @salkar
    @talisman.follow @salkar
    @talisman.reload
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id], Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == true
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @salkar.remove_post_from_community :post => @salkar_post, :from_community => @community_1
    @talisman.reload
    ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 1
    item = ::Inkwell::TimelineItem.where(:owner_id => @talisman.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == false

    @morozovm.reload
    ::Inkwell::TimelineItem.where(:owner_id => @morozovm.id, :owner_type => ::Inkwell::Constants::OwnerTypes::USER).size.should == 0

    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => ::Inkwell::Constants::OwnerTypes::COMMUNITY, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.communities_ids).size.should == 0
  end

  it "admin permissions should be granted" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @salkar.reload
    @morozovm.reload
    @salkar.grant_admin_permissions :to_user => @morozovm, :in_community => @community_1
    @community_1.reload
    @salkar.reload
    @community_1.include_admin?(@morozovm).should == true
    @community_1.admin_level_of(@morozovm).should == 2
  end

  it "admin permissions should be revoked" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.add_admin :admin => @salkar, :user => @morozovm
    @community_1.include_admin?(@morozovm).should == true
    @salkar.revoke_admin_permissions :user => @morozovm, :in_community => @community_1
    @community_1.reload
    @morozovm.reload
    @community_1.include_admin?(@salkar).should == true
    @community_1.include_admin?(@morozovm).should == false
    @community_1.admins_row.size.should == 2
  end

  it "community row should be returned for user" do
    @community_2 = Community.create :name => "Community_1", :owner_id => @talisman.id
    @community_3 = Community.create :name => "Community_1", :owner_id => @talisman.id
    @talisman.reload
    @talisman.communities_row.should == [@community_1.id, @community_2.id, @community_3.id]
  end

  it "admin should be added to community users in open community" do
    @community_1.reload
    @talisman.reload
    @community_1.include_user?(@talisman).should == true
    @community_1.include_admin?(@talisman).should == true
  end

  it "private community with default W access should be created" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.reload
    @morozovm.reload
    @private_community.public.should == false
    @private_community.writers_row.should == [@morozovm.id]
    @private_community.users_row.should == [@morozovm.id]
    @private_community.admins_row.should == [@morozovm.id]
    @private_community.admin_level_of(@morozovm).should == 0
  end

  it "private community with default R access should be created" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.default_user_access = 'r'
    @private_community.save
    @private_community.reload
    @morozovm.reload
    @private_community.public.should == false
    @private_community.include_user?(@morozovm).should == true
    @private_community.include_writer?(@morozovm).should == true
    @private_community.include_admin?(@morozovm).should == true
    @private_community.admin_level_of(@morozovm).should == 0
  end

  it "public community with default W access should be created" do
    @w_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @w_community.reload
    @morozovm.reload
    @w_community.public.should == true
    @w_community.admins_row.should == [@morozovm.id]
    @w_community.admin_level_of(@morozovm).should == 0
    @w_community.writers_row.should == [@morozovm.id]
    @w_community.users_row.should == [@morozovm.id]
  end

  it "public community with default R access should be created" do
    @community = Community.create :name => "Community", :owner_id => @morozovm.id
    @community.default_user_access = 'r'
    @community.save
    @community.reload
    @morozovm.reload
    @community.public.should == true

    relation = ::Inkwell::CommunityUser.where(:user_id => @morozovm.id, :community_id => @community.id).first
    relation.should be
    relation.is_admin.should == true
    relation.user_access.should == "w"
  end

  it "added to public community with default W access user should have W access" do
    @w_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @w_community.reload
    @morozovm.reload
    @w_community.add_user :user => @salkar
    @w_community.reload
    @salkar.reload
    @w_community.include_user?(@salkar).should == true
    ::Inkwell::CommunityUser.exists?(:community_id => @w_community.id, :user_id => @salkar.id, :user_access => "w").should == true
  end

  it "added to public community with default R access user should have R access" do
    @community = Community.create :name => "Community", :owner_id => @morozovm.id
    @community.default_user_access = 'r'
    @community.save
    @community.reload
    @morozovm.reload
    @community.add_user :user => @salkar
    @community.reload
    @salkar.reload
    @community.include_user?(@salkar).should == true
    ::Inkwell::CommunityUser.exists?(:community_id => @community.id, :user_id => @salkar.id, :user_access => "r").should == true
  end

  it "added to private community with default W access user should have W access" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload
    @private_community.include_user?(@salkar).should == true
    @private_community.users_row.should == [@morozovm.id, @salkar.id]
    @private_community.writers_row.should == [@morozovm.id, @salkar.id]
    @salkar.communities_row.should == [@private_community.id]
  end

  it "added to private community with default R access user should have R access" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.default_user_access = 'r'
    @private_community.save
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload
    @private_community.include_user?(@salkar).should == true
    @private_community.users_row.should == [@morozovm.id, @salkar.id]
    @private_community.writers_row.should == [@morozovm.id]
    @salkar.communities_row.should == [@private_community.id]
  end

  it "request invitation should be created (include_invitation_request?)" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    ::Inkwell::CommunityUser.exists?(:user_id => @salkar.id, :community_id => @private_community.id, :active => false, :asked_invitation => true).should == true
    @private_community.include_invitation_request?(@salkar).should == true
  end

  it "request invitation should be created (include_invitation_request?)" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.reload
    @private_community.include_invitation_request?(@salkar).should == false
    @private_community.create_invitation_request @talisman
    @private_community.reload
    @private_community.include_invitation_request?(@salkar).should == false
  end

  it "error should be excepted on try to check invitation request for public community" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @public_community.reload
    expect { @public_community.include_invitation_request?(@salkar) }.to raise_error
  end

  it "invitation request should be created" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    ::Inkwell::CommunityUser.exists?(:user_id => @salkar.id, :community_id => @private_community.id, :active => false, :asked_invitation => true).should == true
  end

  it "invitation request should not be created" do
    expect { @community_1.create_invitation_request(@salkar) }.to raise_error
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    ::Inkwell::CommunityUser.create :user_id => @talisman.id, :community_id => @private_community.id, :active => false, :banned => true
    expect { @private_community.create_invitation_request(@talisman) }.to raise_error
    @private_community.create_invitation_request(@salkar)
    expect { @private_community.create_invitation_request(@salkar) }.to raise_error
  end

  it "user should not be added to public community cause he is banned" do
    ::Inkwell::CommunityUser.create :user_id => @morozovm.id, :community_id => @community_1.id, :active => false, :banned => true
    expect { @morozovm.join @community_1 }.to raise_error
  end

  it "error should be raised on trying to add to community user who already added to it" do
    @salkar.join @community_1
    expect { @salkar.join @community_1 }.to raise_error
  end

  it "invitation request should be rejected" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request(@salkar)
    @private_community.reload
    @private_community.include_invitation_request?(@salkar).should == true
    @private_community.reject_invitation_request :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_invitation_request?(@salkar).should == false
  end

  it "invitation request should not be rejected" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request(@salkar)
    @private_community.add_user :user => @talisman    #only for test
    @private_community.reload
    expect { @private_community.reject_invitation_request :user => @spy, :admin => @morozovm }.to raise_error
    expect { @private_community.reject_invitation_request :user => @salkar }.to raise_error
    expect { @private_community.reject_invitation_request :admin => @morozovm }.to raise_error
    expect { @private_community.reject_invitation_request :user => @salkar, :admin => @talisman }.to raise_error
  end

  it "invitation request should be accepted" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload
    @private_community.include_user?(@salkar).should == true
    @private_community.users_row.should == [@morozovm.id, @salkar.id]
    @private_community.writers_row.should == [@morozovm.id, @salkar.id]
    @salkar.communities_row.should == [@private_community.id]
  end

  it "invitation request should not be accepted" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.add_user :user => @talisman    #only for test
    @private_community.reload

    expect { @private_community.accept_invitation_request :user => @spy, :admin => @morozovm }.to raise_error
    expect { @private_community.accept_invitation_request :user => @salkar }.to raise_error
    expect { @private_community.accept_invitation_request :admin => @morozovm }.to raise_error
    expect { @private_community.accept_invitation_request :user => @salkar, :admin => @talisman }.to raise_error
    @private_community.add_user :user => @salkar    #only for test
    expect { @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm }.to raise_error
  end

  it "user should be removed from private community"  do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.add_user :user => @salkar    #only for test
    @private_community.reload
    @salkar.reload

    @private_community.include_user?(@salkar).should == true
    @private_community.users_row.should == [@morozovm.id, @salkar.id]
    @private_community.writers_row.should == [@morozovm.id, @salkar.id]
    @salkar.communities_row.should == [@private_community.id]

    @private_community.remove_user :admin => @morozovm, :user => @salkar
    @private_community.reload
    @salkar.reload

    @private_community.include_user?(@salkar).should == false
    @private_community.users_row.should == [@morozovm.id]
    @private_community.writers_row.should == [@morozovm.id]
    @salkar.communities_row.should == []
  end

  it "admin should be removed from private community"  do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.add_user :user => @salkar #only for test
    @private_community.add_admin :user => @salkar, :admin => @morozovm
    @private_community.reload
    @salkar.reload

    @private_community.include_user?(@salkar).should == true
    @private_community.include_admin?(@salkar).should == true
    @private_community.users_row.should == [@morozovm.id, @salkar.id]
    @private_community.writers_row.should == [@morozovm.id, @salkar.id]
    @private_community.admins_row.should == [@morozovm.id, @salkar.id]
    @salkar.communities_row.should == [@private_community.id]

    @private_community.remove_user :admin => @morozovm, :user => @salkar
    @private_community.reload
    @salkar.reload

    @private_community.include_user?(@salkar).should == false
    @private_community.users_row.should == [@morozovm.id]
    @private_community.writers_row.should == [@morozovm.id]
    @private_community.admins_row.should == [@morozovm.id]
    @salkar.communities_row.should == []
  end

  it "user should leave private community" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @salkar.leave @private_community
    @salkar.reload
    @private_community.reload

    @private_community.include_user?(@salkar).should == false
    @salkar.communities_row.should == []
  end

  it "user should be kicked from private community" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @morozovm.kick :user => @salkar, :from_community => @private_community
    @salkar.reload
    @private_community.reload

    @private_community.include_user?(@salkar).should == false
    ::Inkwell::CommunityUser.where(:community_id => @private_community.id).size.should == 1
    @salkar.communities_row.should == []
  end

  it "user should not join private community" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    expect { @salkar.join @private_community }.to raise_error
  end

  it "user info should be deleted from community with W access if user is removed" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @public_community.reload
    @morozovm.reload
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    @salkar.reload
    @public_community.reload

    @public_community.include_user?(@salkar).should == true
    @public_community.include_admin?(@salkar).should == true
    @public_community.users_row.should == [@morozovm.id, @salkar.id]
    @public_community.writers_row.should == [@morozovm.id, @salkar.id]
    @salkar.communities_row.should == [@public_community.id]

    @morozovm.kick :user => @salkar, :from_community => @public_community
    @salkar.reload
    @public_community.reload

    @public_community.include_user?(@salkar).should == false
    @public_community.users_row.should == [@morozovm.id]
    @public_community.writers_row.should == [@morozovm.id]
    @salkar.communities_row.should == []
  end

  it "user should be muted" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_muted_user?(@salkar).should == false
    @public_community.mute_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_muted_user?(@salkar).should == true

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_muted_user?(@salkar).should == false
    @private_community.mute_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == true
  end

  it "user should not be muted" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @talisman.join @public_community
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload
    @talisman.reload

    expect { @public_community.mute_user :user => @spy, :admin => @morozovm }.to raise_error
    expect { @public_community.mute_user :user => @salkar }.to raise_error
    expect { @public_community.mute_user :admin => @morozovm }.to raise_error
    expect { @public_community.mute_user :user => @salkar, :admin => @talisman }.to raise_error
    expect { @public_community.mute_user :user => @morozovm, :admin => @morozovm }.to raise_error
    @public_community.add_admin :user => @talisman, :admin => @morozovm
    expect { @public_community.mute_user :user => @morozovm, :admin => @talisman }.to raise_error
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    expect { @public_community.mute_user :user => @salkar, :admin => @talisman }.to raise_error
    @public_community.mute_user :user => @salkar, :admin => @morozovm
    expect { @public_community.mute_user :user => @salkar, :admin => @morozovm }.to raise_error
  end

  it "user should be unmuted" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_muted_user?(@salkar).should == false
    @public_community.mute_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_muted_user?(@salkar).should == true
    @public_community.unmute_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_muted_user?(@salkar).should == false

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_muted_user?(@salkar).should == false
    @private_community.mute_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == true
    @private_community.unmute_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == false
  end

  it "user should not be unmuted" do
    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @talisman
    @private_community.reload
    @private_community.accept_invitation_request :user => @talisman, :admin => @morozovm
    @talisman.reload
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @private_community.mute_user :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload
    @morozovm.reload
    @talisman.reload

    expect { @private_community.unmute_user :user => @spy, :admin => @morozovm }.to raise_error

    expect { @private_community.unmute_user :user => @salkar }.to raise_error
    expect { @private_community.unmute_user :admin => @morozovm }.to raise_error
    expect { @private_community.unmute_user :user => @salkar, :admin => @talisman }.to raise_error
  end

  it "user should be unmuted when he is become admin" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_muted_user?(@salkar).should == false
    @public_community.mute_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_muted_user?(@salkar).should == true
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_muted_user?(@salkar).should == false

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_muted_user?(@salkar).should == false
    @private_community.mute_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == true
    @private_community.add_admin :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == false
  end

  it "user should be banned" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_banned_user?(@salkar).should == false
    @public_community.ban_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_banned_user?(@salkar).should == true
    @public_community.include_user?(@salkar).should == false

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_banned_user?(@salkar).should == false
    @private_community.ban_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == true
    @private_community.include_user?(@salkar).should == false
  end

  it "admin should be banned" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_user?(@salkar).should == true
    @public_community.include_banned_user?(@salkar).should == false
    @public_community.ban_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_banned_user?(@salkar).should == true
    @public_community.include_user?(@salkar).should == false

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @private_community.add_admin :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_user?(@salkar).should == true
    @private_community.include_banned_user?(@salkar).should == false
    @private_community.ban_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == true
    @private_community.include_user?(@salkar).should == false
  end

  it "user with request invitation should be banned" do
    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == false
    @private_community.ban_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == true
    @private_community.include_user?(@salkar).should == false
  end

  it "user should not be banned" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @talisman.join @public_community
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload
    @talisman.reload

    expect { @public_community.ban_user :user => @spy, :admin => @morozovm }.to raise_error
    expect { @public_community.ban_user :user => @salkar }.to raise_error
    expect { @public_community.ban_user :admin => @morozovm }.to raise_error
    expect { @public_community.ban_user :user => @salkar, :admin => @talisman }.to raise_error
    expect { @public_community.ban_user :user => @morozovm, :admin => @morozovm }.to raise_error
    @public_community.add_admin :user => @talisman, :admin => @morozovm
    expect { @public_community.ban_user :user => @morozovm, :admin => @talisman }.to raise_error
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    expect { @public_community.ban_user :user => @salkar, :admin => @talisman }.to raise_error
    @public_community.ban_user :user => @salkar, :admin => @morozovm
    expect { @public_community.ban_user :user => @salkar, :admin => @morozovm }.to raise_error
  end

  it "user should be unbanned" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_banned_user?(@salkar).should == false
    @public_community.ban_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_banned_user?(@salkar).should == true
    @public_community.unban_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_banned_user?(@salkar).should == false

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_banned_user?(@salkar).should == false
    @private_community.ban_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == true
    @private_community.unban_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == false
  end

  it "user should not be unbanned" do
    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @talisman
    @private_community.reload
    @private_community.accept_invitation_request :user => @talisman, :admin => @morozovm
    @talisman.reload
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @private_community.ban_user :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload
    @morozovm.reload
    @talisman.reload

    expect { @private_community.unban_user :user => @spy, :admin => @morozovm }.to raise_error

    expect { @private_community.unban_user :user => @salkar }.to raise_error
    expect { @private_community.unban_user :admin => @morozovm }.to raise_error
    expect { @private_community.unban_user :user => @salkar, :admin => @talisman }.to raise_error
  end

  it "admin should ban another user" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_admin?(@salkar).should == true
    @public_community.include_banned_user?(@salkar).should == false
    @morozovm.ban :user => @salkar, :in_community => @public_community
    @public_community.reload
    @public_community.include_banned_user?(@salkar).should == true
    @public_community.include_user?(@salkar).should == false
    @public_community.include_admin?(@salkar).should == false
  end

  it "user should unban another user" do
    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_banned_user?(@salkar).should == false
    @private_community.ban_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == true
    @morozovm.unban :user => @salkar, :in_community => @private_community
    @private_community.reload
    @private_community.include_banned_user?(@salkar).should == false
  end

  it "user should muted another user" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_muted_user?(@salkar).should == false
    @morozovm.mute :user => @salkar, :in_community => @public_community
    @public_community.reload
    @public_community.include_muted_user?(@salkar).should == true
  end

  it "user should unmute another user" do
    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_muted_user?(@salkar).should == false
    @private_community.mute_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == true
    @morozovm.unmute :user => @salkar, :in_community => @private_community
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == false
  end

  it "muted user should not be able to add post to community" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_muted_user?(@salkar).should == false
    @public_community.mute_user :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.include_muted_user?(@salkar).should == true
    expect { @public_community.add_post :user => @salkar, :post => @salkar_post }.to raise_error

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_muted_user?(@salkar).should == false
    @private_community.mute_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.include_muted_user?(@salkar).should == true
    expect { @private_community.add_post :user => @salkar, :post => @salkar_post }.to raise_error
  end

  it "user should be writer in community (include_writer?)" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_writer?(@morozovm).should == true
    @public_community.include_writer?(@salkar).should == true

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_writer?(@morozovm).should == true
    @private_community.include_writer?(@salkar).should == true
  end

  it "user should not be writer in community (include_writer?)" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @public_community.include_writer?(@morozovm).should == true
    @public_community.include_writer?(@salkar).should == false
    @public_community.include_writer?(@talisman).should == false

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.default_user_access = 'r'
    @private_community.save
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.include_writer?(@morozovm).should == true
    @private_community.include_writer?(@salkar).should == false
    @private_community.include_writer?(@talisman).should == false
  end

  it "user should be able to send post to community (can_send_post_to_community?)" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @morozovm.can_send_post_to_community?(@public_community).should == true
    @salkar.can_send_post_to_community?(@public_community).should == true

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @morozovm.reload
    @private_community.reload

    @morozovm.can_send_post_to_community?(@private_community).should == true
    @salkar.can_send_post_to_community?(@private_community).should == true
  end

  it "user should be able to send post to community (can_send_post_to_community?)" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload

    @morozovm.mute :user => @salkar, :in_community => @public_community
    @public_community.reload
    @salkar.can_send_post_to_community?(@public_community).should == false
    @talisman.can_send_post_to_community?(@public_community).should == false
    @public_community.default_user_access = 'r'
    @public_community.save
    @talisman.join @public_community
    @public_community.reload
    @talisman.reload
    @talisman.can_send_post_to_community?(@public_community).should == false

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.default_user_access = 'r'
    @private_community.save
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @morozovm.mute :user => @salkar, :in_community => @private_community
    @private_community.reload
    @salkar.can_send_post_to_community?(@private_community).should == false
    @talisman.can_send_post_to_community?(@private_community).should == false
    @private_community.default_user_access = 'r'
    @private_community.save
    @private_community.create_invitation_request @talisman
    @private_community.reload
    @private_community.accept_invitation_request :user => @talisman, :admin => @morozovm
    @talisman.reload
    @private_community.reload
    @talisman.can_send_post_to_community?(@private_community).should == false
  end

  it "post should be sended to community" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @salkar.send_post_to_community :to_community => @public_community, :post => @salkar_post
    @salkar_post.communities_row.should == [@public_community.id]

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload
    @salkar.send_post_to_community :to_community => @private_community, :post => @salkar_post
    @salkar_post.communities_row.should == [@public_community.id, @private_community.id]
  end

  it "post should not be sended to community" do
    @public_community_r = Community.create :name => "Community", :owner_id => @morozovm.id
    @talisman.join @public_community_r
    @public_community_r.default_user_access = 'r'
    @public_community_r.save
    @salkar.join @public_community_r
    @salkar.reload
    @public_community_r.reload
    expect {@salkar.send_post_to_community :to_community => @public_community_r, :post => @salkar_post}.to raise_error
    @salkar_post.communities_row.should == []

    @private_community = Community.create :name => "Community", :owner_id => @morozovm.id, :public => false

    @private_community.create_invitation_request @talisman
    @private_community.reload
    @private_community.accept_invitation_request :user => @talisman, :admin => @morozovm
    @salkar.reload
    @private_community.reload

    @private_community.default_user_access = 'r'
    @private_community.save
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @salkar.reload
    @private_community.reload
    expect {@salkar.send_post_to_community :to_community => @private_community, :post => @salkar_post}.to raise_error
    @salkar_post.communities_row.should == []

    @spy_post = @spy.posts.create :body => "spy_post_test_body"
    expect {@spy.send_post_to_community :to_community => @public_community_r, :post => @spy_post}.to raise_error
    expect {@spy.send_post_to_community :to_community => @private_community, :post => @spy_post}.to raise_error

    @talisman_post = @talisman.posts.create :body => "morozovm_post_test_body"
    @morozovm.mute :user => @talisman, :in_community => @public_community_r
    @morozovm.mute :user => @talisman, :in_community => @private_community
    @public_community_r.reload
    @private_community.reload
    expect {@talisman.send_post_to_community :to_community => @public_community_r, :post => @talisman_post}.to raise_error
    expect {@talisman.send_post_to_community :to_community => @private_community, :post => @talisman_post}.to raise_error
  end

  it "admin should be a writer" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @salkar.join @public_community
    @salkar.reload
    @public_community.reload
    @morozovm.reload
    @public_community.include_writer?(@salkar).should == false

    @public_community.add_admin :admin => @morozovm, :user => @salkar
    @public_community.reload
    @salkar.reload
    @public_community.include_writer?(@salkar).should == true
  end

  it "user should be able to request invitation to private community" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @salkar.request_invitation @private_community
    ::Inkwell::CommunityUser.exists?(:user_id => @salkar.id, :community_id => @private_community.id, :active => false, :asked_invitation => true).should == true
  end

  it "admin should be able to accept invitation request" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @morozovm.approve_invitation_request :user => @salkar, :community => @private_community
    @salkar.reload
    @private_community.reload
    @private_community.include_user?(@salkar).should == true
    @private_community.users_row.should == [@morozovm.id,@salkar.id]
    @private_community.writers_row.should == [@morozovm.id,@salkar.id]
    @salkar.communities_row.should == [@private_community.id]
  end

  it "admin should be able to reject invitation request" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.create_invitation_request(@salkar)
    @private_community.reload
    @private_community.include_invitation_request?(@salkar).should == true
    @morozovm.reject_invitation_request :user => @salkar, :community => @private_community
    @private_community.reload
    @private_community.include_invitation_request?(@salkar).should == false
  end

  it "default user access should changed to write" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @public_community.reload
    @public_community.default_user_access.should == 'r'
    @public_community.change_default_access_to_write
    @public_community.reload
    @public_community.default_user_access.should == 'w'
  end

  it "default user access should changed to read" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.reload
    @public_community.default_user_access.should == 'w'
    @public_community.change_default_access_to_read
    @public_community.reload
    @public_community.default_user_access.should == 'r'
  end

  it "write access should be granted in the public community" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @salkar.join @public_community
    @talisman.join @public_community
    @spy.join @public_community

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    @public_community.set_write_access [@salkar.id, @talisman.id]

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    writers_ids = @public_community.writers_row
    writers_ids.include?(@salkar.id).should == true
    writers_ids.include?(@talisman.id).should == true
    writers_ids.include?(@spy.id).should == false
    @public_community.include_writer?(@salkar).should == true
    @public_community.include_writer?(@talisman).should == true
    @public_community.include_writer?(@spy).should == false
  end

  it "write access should be granted in the private community" do
    @private_community = Community.create :name => "community", :owner_id => @morozovm.id, :public => false
    @private_community.default_user_access = 'r'
    @private_community.save

    @private_community.add_user :user => @salkar    #only for test
    @private_community.add_user :user => @talisman    #only for test
    @private_community.add_user :user => @spy    #only for test

    @private_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    @private_community.set_write_access [@salkar.id, @talisman.id]

    @private_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    writers_ids = @private_community.writers_row
    writers_ids.include?(@salkar.id).should == true
    writers_ids.include?(@talisman.id).should == true
    writers_ids.include?(@spy.id).should == false
    @private_community.include_writer?(@salkar).should == true
    @private_community.include_writer?(@talisman).should == true
    @private_community.include_writer?(@spy).should == false
  end

  it "error should raised when W access granted to user with W access" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @talisman.join @public_community
    @spy.join @public_community

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    expect {@public_community.set_write_access @public_community.users_row}.to raise_error
    (@public_community.writers_row & [@morozovm.id, @salkar.id, @talisman.id, @spy.id]).size.should == 4
  end

  it "passed empty array should lead to error" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    expect {@public_community.set_write_access []}.to raise_error
    @private_community = Community.create :name => "community", :owner_id => @morozovm.id, :public => false
    expect {@private_community.set_write_access []}.to raise_error
  end

  it "write access should not be granted" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    expect {@public_community.set_write_access [@talisman.id]}.to raise_error
    expect {@public_community.set_write_access @talisman}.to raise_error
    expect {@public_community.set_write_access [-1]}.to raise_error
  end

  it "read access should be set in the public community" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @talisman.join @public_community
    @spy.join @public_community

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    @public_community.set_read_access [@salkar.id, @talisman.id]

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    writers_ids = @public_community.writers_row
    writers_ids.include?(@salkar.id).should == false
    writers_ids.include?(@talisman.id).should == false
    writers_ids.include?(@spy.id).should == true
    @public_community.include_writer?(@salkar).should == false
    @public_community.include_writer?(@talisman).should == false
    @public_community.include_writer?(@spy).should == true
  end

  it "read access should be set in the private community" do
    @private_community = Community.create :name => "community", :owner_id => @morozovm.id, :public => false

    @private_community.add_user :user => @salkar #only for test
    @private_community.add_user :user => @talisman #only for test
    @private_community.add_user :user => @spy #only for test

    @private_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    @private_community.set_read_access [@salkar.id, @talisman.id]

    @private_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    salkar_relation = ::Inkwell::CommunityUser.where(:user_id => @salkar.id, :community_id => @private_community.id).first
    spy_relation = ::Inkwell::CommunityUser.where(:user_id => @spy.id, :community_id => @private_community.id).first
    talisman_relation = ::Inkwell::CommunityUser.where(:user_id => @talisman.id, :community_id => @private_community.id).first
    salkar_relation.user_access.should == "r"
    spy_relation.user_access.should == "w"
    talisman_relation.user_access.should == "r"

    @private_community.include_writer?(@salkar).should == false
    @private_community.include_writer?(@talisman).should == false
    @private_community.include_writer?(@spy).should == true
  end

  it "error should raised when R access set to user with R access" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @salkar.join @public_community
    @talisman.join @public_community
    @spy.join @public_community

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    expect { @public_community.set_read_access (@public_community.users_row - [@morozovm.id]) }.to raise_error
    @public_community.writers_row.should == [@morozovm.id]
  end

  it "passed empty array should lead to error" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    expect {@public_community.set_read_access []}.to raise_error
    @private_community = Community.create :name => "community", :owner_id => @morozovm.id, :public => false
    expect {@private_community.set_read_access []}.to raise_error
  end

  it "write access should not be granted" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    expect { @public_community.set_read_access [@salkar.id, @talisman.id] }.to raise_error
    expect { @public_community.set_read_access [@talisman.id] }.to raise_error
    expect { @public_community.set_read_access @talisman }.to raise_error
    expect { @public_community.set_read_access [-1] }.to raise_error

    expect { @public_community.set_read_access [@morozovm.id] }.to raise_error
  end

  it "admins ids should be returned" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @talisman.join @public_community
    @salkar.join @public_community
    @spy.join @public_community
    @spy.reload
    @salkar.reload
    @public_community.reload
    @morozovm.reload
    @talisman.reload
    @public_community.add_admin :user => @talisman, :admin => @morozovm
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.admins_row.should == [@morozovm.id, @talisman.id, @salkar.id]
  end

  it "writers ids should be returned" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @talisman.join @public_community
    @salkar.join @public_community
    @spy.join @public_community
    @spy.reload
    @salkar.reload
    @public_community.reload
    @morozovm.reload
    @talisman.reload
    @public_community.writers_row.should == [@morozovm.id, @talisman.id, @salkar.id, @spy.id]
  end

  it "counters should be incremented when user enters into the community" do
    @community_1.reload
    @community_1.add_user :admin => @talisman, :user => @salkar
    @community_1.reload
    @community_1.user_count.should == 2
    @salkar.reload
    @salkar.community_count.should == 1
    @talisman.reload
    @talisman.community_count.should == 1
  end

  it "counters should be incremented for community owner when he creates community" do
    @community_1.reload
    @community_1.user_count.should == 1
    @talisman.community_count.should == 1
  end

  it "counters should be decremented when user leaves community" do
    @community_1.reload
    @community_1.add_user :admin => @talisman, :user => @salkar
    @community_1.reload
    @salkar.reload
    @community_1.user_count.should == 2
    @community_1.remove_user :admin => @talisman, :user => @salkar
    @community_1.reload
    @community_1.user_count.should == 1
    @salkar.reload
    @salkar.community_count.should == 0
    @talisman.reload
    @talisman.community_count.should == 1
  end

  it "counters should be decremented when community has been destroyed" do
    @community_1.add_user :admin => @talisman, :user => @salkar
    @community_1.destroy
    @salkar.reload
    @salkar.community_count.should == 0
    @talisman.reload
    @talisman.community_count.should == 0
  end

  it "writer counter should be incremented when user enters to community" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.add_user :user => @salkar
    @public_community.reload
    @public_community.writer_count.should == 2
  end

  it "writer counter should not be incremented when user enters to community" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @public_community.add_user :user => @salkar
    @public_community.reload
    @public_community.writer_count.should == 1
  end

  it "writer counter should be incremented for community owner" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.reload
    @public_community.writer_count.should == 1
  end

  it "writer counter should be decremented when user is removed" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.add_user :user => @salkar
    @public_community.reload
    @public_community.remove_user :user => @salkar
    @public_community.reload
    @public_community.writer_count.should == 1
  end

  it "writer counter should be decremented when user is removed" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @public_community.add_user :user => @salkar
    @public_community.remove_user :user => @salkar
    @public_community.reload
    @public_community.writer_count.should == 1
  end

  it "writer count should be incremented when admin gives W access to user" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @public_community.reload
    @public_community.add_user :user => @salkar
    @public_community.reload
    @public_community.set_write_access [@salkar.id]
    @public_community.reload
    @public_community.writer_count.should == 2
  end

  it "writer and user counters should be decremeted when user destroy his accaunt" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.reload
    @public_community.add_user :user => @salkar
    @public_community.reload
    @salkar.reload
    @salkar.destroy
    @public_community.reload
    @public_community.user_count.should == 1
    @public_community.writer_count.should == 1
  end

  it "writer count should be decremented when admin set R access for user" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.reload
    @public_community.add_user :user => @salkar
    @public_community.reload
    @public_community.set_read_access [@salkar.id]
    @public_community.reload
    @public_community.writer_count.should == 1
  end

  it "reader count should be returned for community" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.reload
    @public_community.reader_count.should == 0
    @public_community.add_user :user => @salkar
    @public_community.reload
    @public_community.reader_count.should == 0
    @public_community.set_read_access [@salkar.id]
    @public_community.reload
    @public_community.reader_count.should == 1
    @public_community.default_user_access = 'r'
    @public_community.save
    @public_community.add_user :user => @talisman
    @public_community.reload
    @public_community.reader_count.should == 2
  end

  it "community should not be created if owner id is nonexistent" do
    c_size = Community.all.size
    expect {@public_community = Community.create :name => "community", :owner_id => -1}.to raise_error
    Community.all.size.should == c_size
  end

  it "admin counter should be incremented when admin is added" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.reload
    @public_community.add_user :user => @salkar
    @public_community.reload
    @public_community.admin_count.should == 1
    @public_community.add_admin :user => @salkar, :admin => @morozovm
    @public_community.reload
    @public_community.admin_count.should == 2
  end

  it "admin counter should be 1 after community is created" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.reload
    @public_community.admin_count.should == 1
  end

  it "admin counter should be decremented after admin is removed" do
    @community_1.add_user :user => @salkar
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.admin_count.should == 2
    @community_1.remove_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.admin_count.should == 1
  end

  it "admin counter should be decremeted when admin is removed from community" do
    @community_1.add_user :user => @salkar
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.admin_count.should == 2
    @community_1.remove_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.admin_count.should == 1
  end

  it "admin counter should be decremented when admin destroy his account" do
    @community_1.add_user :user => @salkar
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.admin_count.should == 2
    @salkar.destroy
    @community_1.reload
    @community_1.admin_count.should == 1
  end

  it "muted counter should be incremented when admin mutes user" do
    @community_1.add_user :user => @salkar
    @community_1.muted_count.should == 0
    @community_1.mute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 1
  end

  it "muted counter should be decreaded when admin status is getting by muted user" do
    @community_1.add_user :user => @salkar
    @community_1.mute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 1
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 0
  end

  it "muted counter should be decreased when admin unmutes user" do
    @community_1.add_user :user => @salkar
    @community_1.mute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 1
    @community_1.unmute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 0
  end

  it "muted counter should be decreased when muted user is removed from community" do
    @community_1.add_user :user => @salkar
    @community_1.mute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 1
    @community_1.remove_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 0
  end

  it "muted counter should be decreased when muted user destroys his accaunt" do
    @community_1.add_user :user => @salkar
    @community_1.mute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_count.should == 1
    @salkar.destroy
    @community_1.reload
    @community_1.muted_count.should == 0
  end

  it "banned counter should be increased when admin bans user" do
    @community_1.add_user :user => @salkar
    @community_1.ban_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.banned_count.should == 1
    @community_1.include_banned_user?(@salkar).should == true
  end

  it "banned counter should be decreased when admin unbans user" do
    @community_1.add_user :user => @salkar
    @community_1.ban_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.banned_count.should == 1
    @community_1.include_banned_user?(@salkar).should == true
    @community_1.unban_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.banned_count.should == 0
    @community_1.include_banned_user?(@salkar).should == false
  end

  it "banned counter should be decremeted when user destroys his accaunt" do
    @community_1.add_user :user => @salkar
    @community_1.ban_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.banned_count.should == 1
    @salkar.destroy
    @community_1.reload
    @community_1.banned_count.should == 0
  end

  it "user counter should be decremented when admin ban user" do
    @community_1.add_user :user => @salkar
    @community_1.reload
    @community_1.user_count.should == 2
    @community_1.ban_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.user_count.should == 1
  end

  it "invitation counter should be incremented when user asks invitation" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.reload
    @private_community.invitation_count.should == 0
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.invitation_count.should == 1
  end

  it "invitation counter should be decremented when admin accept invitation" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.reload
    @private_community.invitation_count.should == 0
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.invitation_count.should == 1
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.invitation_count.should == 0
  end

  it "invitation counter should be decremented when admin reject invitation" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.reload
    @private_community.invitation_count.should == 0
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.invitation_count.should == 1
    @private_community.reject_invitation_request :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.invitation_count.should == 0
  end

  it "invitation counter should be decremented when admin ban asked user" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.reload
    @private_community.invitation_count.should == 0
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.invitation_count.should == 1
    @private_community.ban_user :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.invitation_count.should == 0
  end

  it "invitation counter should be decremented when user destroys his accaunt" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.reload
    @private_community.invitation_count.should == 0
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.invitation_count.should == 1
    @salkar.destroy
    @private_community.reload
    @private_community.invitation_count.should == 0
  end

  it "communities should be returned for their member" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @talisman.join @public_community
    communities = @talisman.communities
    communities.include?(@community_1).should == true
    communities.include?(@public_community).should == true
    communities.size.should == 2
  end

  it "communities should be returned for their member" do
    @public_community = Community.create :name => "Community", :owner_id => @morozovm.id
    @talisman.join @public_community
    @salkar.join @public_community
    @spy.join @public_community
    users = @public_community.users
    users.include?(@morozovm).should == true
    users.include?(@talisman).should == true
    users.include?(@salkar).should == true
    users.include?(@spy).should == true
    users.size.should == 4
  end

  it "admins should be returned for community" do
    @community_1.admins.should == [@talisman]
    @community_1.add_user :user => @salkar, :admin => @talisman
    @community_1.admins.should == [@talisman]
    @community_1.add_admin :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.admins.should == [@talisman, @salkar]
  end

  it "writers should be returned for community" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save
    @public_community.reload
    @public_community.writers.should == [@morozovm]
    @salkar.join @public_community
    @public_community.reload
    @public_community.writers.should == [@morozovm]
    @public_community.set_write_access [@salkar.id]
    @public_community.reload
    @public_community.writers.should == [@morozovm, @salkar]
  end

  it "muted users should be returned for community" do
    @community_1.muted_users.should == []
    @community_1.add_user :user => @salkar
    @community_1.mute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_users.should == [@salkar]
  end

  it "banned users should be returned for community" do
    @community_1.banned_users.should == []
    @community_1.add_user :user => @salkar
    @community_1.ban_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.banned_users.should == [@salkar]
  end

  it "asked invitation users should be returned for community" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.asked_invitation_users.should == []
    @private_community.create_invitation_request @salkar
    @private_community.reload
    @private_community.asked_invitation_users.should == [@salkar]
    @private_community.accept_invitation_request :user => @salkar, :admin => @morozovm
    @private_community.reload
    @private_community.asked_invitation_users.should == []
  end

  it "invitation_uids should be returned for community" do
    @private_community = Community.create :name => "Private Community", :owner_id => @morozovm.id, :public => false
    @private_community.invitations_row.should == []
    @private_community.create_invitation_request @salkar
    @private_community.create_invitation_request @talisman
    @private_community.reload
    @private_community.invitations_row.should == [@salkar.id, @talisman.id]
  end

  it "user should not be destroyed if he is owner of some communities" do
    expect {@talisman.destroy}.to raise_error
    @talisman.reload
    @talisman.should be
  end

  it "blog_items should be returned for community" do
    @community_1.blog_items.size.should == 0
    @community_1.add_user :user => @salkar
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community_1
    @community_1.reload
    @community_1.blog_items.size.should == 1
    @community_1.blog_items.should == ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => 'c')
    @salkar_post_1 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar.send_post_to_community :post => @salkar_post_1, :to_community => @community_1
    @community_1.reload
    @community_1.blog_items.size.should == 2
    @community_1.blog_items.should == ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :owner_type => 'c')
  end

  it "posts should be returned for community" do
    @community_1.add_user :user => @salkar
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community_1
    @community_1.reload
    @community_1.posts.size.should == 1
    @community_1.posts.should == [@salkar_post]
    @salkar_post_1 = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar.send_post_to_community :post => @salkar_post_1, :to_community => @community_1
    @community_1.reload
    @community_1.posts.size.should == 2
    @community_1.posts.should == [@salkar_post, @salkar_post_1]
  end

  it "blog_items should be returned for post" do
    @salkar_post.blog_items.size.should == 1
    @community_1.add_user :user => @salkar
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community_1
    @salkar_post.reload
    @salkar_post.blog_items.size.should == 2
    @public_community = Community.create :name => "community", :owner_id => @salkar.id
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @public_community
    @salkar_post.reload
    @salkar_post.blog_items.size.should == 3
  end

  it "communities should be returned for post" do
    @salkar_post.communities.size.should == 0
    @community_1.add_user :user => @salkar
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community_1
    @salkar_post.reload
    @salkar_post.communities.size.should == 1
    @public_community = Community.create :name => "community", :owner_id => @salkar.id
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @public_community
    @salkar_post.reload
    @salkar_post.communities.size.should == 2
    @salkar_post.communities.should == [@community_1, @public_community]
  end

  it "muted uids should be returned for community" do
    @community_1.muted_users.should == []
    @community_1.add_user :user => @salkar
    @community_1.mute_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.muted_row.should == [@salkar.id]
  end

  it "banned uids should be returned for community" do
    @community_1.banned_row.should == []
    @community_1.add_user :user => @salkar
    @community_1.ban_user :user => @salkar, :admin => @talisman
    @community_1.reload
    @community_1.banned_row.should == [@salkar.id]
  end

  it "read access should be set in the public community when users passed" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @salkar.join @public_community
    @talisman.join @public_community
    @spy.join @public_community

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    @public_community.set_read_access [@salkar, @talisman]

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload
    @public_community.readers_row.size.should == 2
  end

  it "write access should be set in the public community when users passed" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save

    @salkar.join @public_community
    @talisman.join @public_community
    @spy.join @public_community

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload

    @public_community.set_write_access [@salkar, @talisman]

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload
    @public_community.readers_row.size.should == 1
    @public_community.writers_row.size.should == 3
  end

  it "readers uids should be returned for community" do
    @public_community = Community.create :name => "community", :owner_id => @morozovm.id
    @public_community.default_user_access = 'r'
    @public_community.save

    @salkar.join @public_community
    @talisman.join @public_community
    @spy.join @public_community

    @public_community.reload
    @salkar.reload
    @talisman.reload
    @spy.reload
    @public_community.readers_row.should == [@salkar.id, @talisman.id, @spy.id]
  end


end