require "spec_helper"

describe "Community" do
  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @talisman = User.create :nick => "Talisman"
    @community_1 = Community.create :name => "Community_1", :owner_id => @talisman.id
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
  end

  it "user should been added to community" do
    users_ids = ActiveSupport::JSON.decode @community_1.users_ids
    users_ids.size.should == 1
    communities_ids = ActiveSupport::JSON.decode @salkar.communities_ids
    communities_ids.size.should == 0
    @community_1.add_user :user => @salkar
    @community_1.reload
    @salkar.reload
    users_ids = ActiveSupport::JSON.decode @community_1.users_ids
    users_ids.size.should == 2
    users_ids[1].should == @salkar.id
    communities_ids = ActiveSupport::JSON.decode @salkar.communities_ids
    communities_ids.size.should == 1
    communities_ids[0].should == @community_1.id
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
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    @talisman = User.create :nick => "Talisman"
    @community_1.add_user :user => @talisman
    @talisman.reload
    tline = @talisman.timeline_items
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
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    @community_1.add_user :user => @talisman
    @talisman.reload
    tline = @talisman.timeline_items
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
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    @community_1.add_user :user => @salkar
    @salkar.reload
    tline = @salkar.timeline_items
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
    @salkar.communities_ids = "[#{@community_1.id}]"
    @community_1.users_ids = "[#{@salkar.id}]"
    @community_1.save
    @salkar.save
    @community_1.include_user?(@salkar).should == true
  end

  it "user should not be admin" do
    @community_1.include_admin?(@salkar).should == false
  end

  it "user should be admin" do
    @salkar.admin_of = ActiveSupport::JSON.encode [{'community_id' => @salkar.id}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{'user_id' => @salkar.id}]
    @community_1.save
    @community_1.include_admin?(@salkar).should == true
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
    ActiveSupport::JSON.decode(@community_1.admins_info).size.should == 1
    ActiveSupport::JSON.decode(@salkar.admin_of).size.should == 0
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
    ::Inkwell::BlogItem.create :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post3.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post4.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post5.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post6.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post7.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    ::Inkwell::BlogItem.create :item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_id => @community_1.id, :is_owner_user => false
    @community_1.add_user :user => @talisman
    @talisman.reload
    @community_1.reload
    tline = @talisman.timeline_items
    tline.size.should == 12
    @community_1.include_user?(@talisman).should == true
    @community_1.remove_user :user => @talisman
    @talisman.reload
    tline = @talisman.timeline_items
    tline.size.should == 9
    tline.where(:item_id => @morozovm_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.should == nil
    tline.where(:item_id => @morozovm_post1.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.should == nil
    tline.where(:item_id => @morozovm_post2.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.should == nil
    ActiveSupport::JSON.decode(tline.where(:item_id => @salkar_post8.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).first.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
  end

  it "admin level of user should be returned" do
    @salkar.admin_of = ActiveSupport::JSON.encode [{:community_id => @community_1.id, :admin_level => 3}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{:admin_id => @salkar.id, :admin_level => 3}]
    @community_1.save
    @community_1.admin_level_of(@salkar).should == 3
  end

  it "admin level of user should not be returned" do
    expect { @community_1.admin_level_of(@salkar) }.to raise_error
  end

  it "admin should be added" do
    @salkar.admin_of = ActiveSupport::JSON.encode [{:community_id => @community_1.id, :admin_level => 0}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{:admin_id => @salkar.id, :admin_level => 0}]
    @community_1.save
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.reload
    @salkar.reload
    @morozovm.reload
    @community_1.add_admin :admin => @salkar, :user => @morozovm
    @community_1.reload
    @salkar.reload
    @community_1.include_admin?(@morozovm).should == true
    @community_1.admin_level_of(@morozovm).should == 1
  end

  it "admin should not be added" do
    expect { @community_1.add_admin(:user => @salkar) }.to raise_error
    expect { @community_1.add_admin(:user => @salkar, :admin => @talisman) }.to raise_error
    expect { @community_1.add_admin(:user => "@salkar", :admin => "@talisman") }.to raise_error

    @salkar.admin_of = ActiveSupport::JSON.encode [{:community_id => @community_1.id, :admin_level => 0}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{:admin_id => @salkar.id, :admin_level => 0}]
    @community_1.save
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.reload
    @salkar.reload
    @morozovm.reload
    expect { @community_1.add_admin :admin => @salkar, :user => @salkar }.to raise_error
    @community_1.reload
    @salkar.reload
    ActiveSupport::JSON.decode(@community_1.admins_info).size.should == 1
    ActiveSupport::JSON.decode(@salkar.admin_of).size.should == 1
  end

  it "admin should be removed" do
    @salkar.admin_of = ActiveSupport::JSON.encode [{:community_id => @community_1.id, :admin_level => 0}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{:admin_id => @salkar.id, :admin_level => 0}]
    @community_1.save
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
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
    ActiveSupport::JSON.decode(@community_1.admins_info).size.should == 1
    ActiveSupport::JSON.decode(@morozovm.admin_of).size.should == 0

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

    @salkar.admin_of = ActiveSupport::JSON.encode [{:community_id => @community_1.id, :admin_level => 0}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{:admin_id => @salkar.id, :admin_level => 0}]
    @community_1.save
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.reload
    @salkar.reload
    @morozovm.reload
    expect { @community_1.remove_admin :user => @salkar, :admin => @salkar }.to raise_error

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
    @salkar.timeline_items.size.should == 3
    @talisman.timeline_items.size.should == 12
    @morozovm.timeline_items.size.should == 9
    id = @community_1.id

    @community_1.reload
    @community_1.destroy
    ::Inkwell::BlogItem.all.size.should == 12
    ::Inkwell::BlogItem.where(:owner_id => id, :is_owner_user => false).size.should == 0
    @salkar.timeline_items.size.should == 3
    @talisman.timeline_items.size.should == 3
    @morozovm.timeline_items.size.should == 0
    @salkar.timeline_items.each do |item|
      item.has_many_sources.should == false
      ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @morozovm.id, 'type' => 'following']]
    end
    @talisman.timeline_items.each do |item|
      item.has_many_sources.should == false
      ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @morozovm.id, 'type' => 'following']]
    end
    @salkar.reload
    @talisman.reload
    @morozovm.reload
    @salkar.communities_row.size.should == 0
    @talisman.communities_row.size.should == 0
    @morozovm.communities_row.size.should == 0
    ActiveSupport::JSON.decode(@talisman.admin_of).size.should == 0
  end

  it "post should be added to community blogline and user's timeline" do
    @community_1.add_user :user => @salkar
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :is_owner_user => false, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @community_1.add_post :post => @salkar_post, :user => @salkar
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :is_owner_user => false, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    @salkar.timeline_items.size.should == 0
    @talisman.timeline_items.size.should == 1
    @talisman.timeline_items.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = @talisman.timeline_items.first
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
    @talisman.timeline_items.size.should == 1
    @talisman.timeline_items.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    @morozovm.timeline_items.size.should == 0
    @salkar.timeline_items.size.should == 0

    @community_1.add_post :post => @salkar_post, :user => @salkar
    @talisman.timeline_items.size.should == 1
    @talisman.timeline_items.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = @talisman.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following'], Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == true

    @salkar.timeline_items.size.should == 0

    @morozovm.reload
    @morozovm.timeline_items.size.should == 1
    @morozovm.timeline_items.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = @morozovm.timeline_items.first
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
    @talisman.timeline_items.size.should == 1
    item = @talisman.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id], Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == true
    @morozovm.timeline_items.size.should == 1
    item = @morozovm.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @community_1.remove_post :post => @salkar_post, :user => @salkar
    @talisman.reload
    @talisman.timeline_items.size.should == 1
    item = @talisman.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == false

    @morozovm.reload
    @morozovm.timeline_items.size.should == 0

    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :is_owner_user => false, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.communities_ids).size.should == 0
  end

  it "post should be removed by admin from community" do
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.add_post :post => @salkar_post, :user => @salkar
    @talisman.follow @salkar
    @talisman.reload
    @talisman.timeline_items.size.should == 1
    item = @talisman.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id], Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == true
    @morozovm.timeline_items.size.should == 1
    item = @morozovm.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @salkar.reload
    @talisman.reload
    @community_1.remove_post :post => @salkar_post, :user => @talisman
    @talisman.reload
    @talisman.timeline_items.size.should == 1
    item = @talisman.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == false

    @morozovm.reload
    @morozovm.timeline_items.size.should == 0

    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :is_owner_user => false, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
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
    users_ids = ActiveSupport::JSON.decode @community_1.users_ids
    users_ids.size.should == 1
    communities_ids = ActiveSupport::JSON.decode @salkar.communities_ids
    communities_ids.size.should == 0
    @salkar.join @community_1
    @community_1.reload
    @salkar.reload
    users_ids = ActiveSupport::JSON.decode @community_1.users_ids
    users_ids.size.should == 2
    users_ids[1].should == @salkar.id
    communities_ids = ActiveSupport::JSON.decode @salkar.communities_ids
    communities_ids.size.should == 1
    communities_ids[0].should == @community_1.id
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
    ActiveSupport::JSON.decode(@community_1.admins_info).size.should == 1
    ActiveSupport::JSON.decode(@salkar.admin_of).size.should == 0
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
    ActiveSupport::JSON.decode(@community_1.admins_info).size.should == 1
    ActiveSupport::JSON.decode(@salkar.admin_of).size.should == 0
  end

  it "post should be sended to community" do
    @community_1.add_user :user => @salkar
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :is_owner_user => false, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community_1
    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :is_owner_user => false, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    @salkar.timeline_items.size.should == 0
    @talisman.timeline_items.size.should == 1
    @talisman.timeline_items.where(:item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 1
    item = @talisman.timeline_items.first
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
    @talisman.timeline_items.size.should == 1
    item = @talisman.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id], Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == true
    @morozovm.timeline_items.size.should == 1
    item = @morozovm.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['community_id' => @community_1.id]]
    item.has_many_sources.should == false

    @salkar.remove_post_from_community :post => @salkar_post, :from_community => @community_1
    @talisman.reload
    @talisman.timeline_items.size.should == 1
    item = @talisman.timeline_items.first
    ActiveSupport::JSON.decode(item.from_source).should == [Hash['user_id' => @salkar.id, 'type' => 'following']]
    item.has_many_sources.should == false

    @morozovm.reload
    @morozovm.timeline_items.size.should == 0

    ::Inkwell::BlogItem.where(:owner_id => @community_1.id, :is_owner_user => false, :item_id => @salkar_post.id, :item_type => ::Inkwell::Constants::ItemTypes::POST).size.should == 0
    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.communities_ids).size.should == 0
  end

  it "admin permissions should be granted" do
    @salkar.admin_of = ActiveSupport::JSON.encode [{:community_id => @community_1.id, :admin_level => 0}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{:admin_id => @salkar.id, :admin_level => 0}]
    @community_1.save
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.reload
    @salkar.reload
    @morozovm.reload
    @salkar.grant_admin_permissions :to_user => @morozovm, :in_community => @community_1
    @community_1.reload
    @salkar.reload
    @community_1.include_admin?(@morozovm).should == true
    @community_1.admin_level_of(@morozovm).should == 1
  end

  it "admin permissions should be revoked" do
    @salkar.admin_of = ActiveSupport::JSON.encode [{:community_id => @community_1.id, :admin_level => 0}]
    @salkar.save
    @community_1.admins_info = ActiveSupport::JSON.encode [{:admin_id => @salkar.id, :admin_level => 0}]
    @community_1.save
    @community_1.add_user :user => @salkar
    @community_1.add_user :user => @morozovm
    @community_1.reload
    @salkar.reload
    @morozovm.reload
    @community_1.add_admin :admin => @salkar, :user => @morozovm
    @community_1.reload
    @morozovm.reload
    @community_1.include_admin?(@morozovm).should == true
    @salkar.revoke_admin_permissions :user => @morozovm, :in_community => @community_1
    @community_1.reload
    @morozovm.reload
    @community_1.include_admin?(@salkar).should == true
    @community_1.include_admin?(@morozovm).should == false
    ActiveSupport::JSON.decode(@community_1.admins_info).size.should == 1
    ActiveSupport::JSON.decode(@morozovm.admin_of).size.should == 0
  end

end