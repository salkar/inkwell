require "spec_helper"

describe "Category" do
  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @talisman = User.create :nick => "Talisman"
    @spy = User.create :nick => "Spy"
    @community = Community.create :name => "Community_1", :owner_id => @talisman.id
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar.reload
    @talisman.reload
    @morozovm.reload
    @community.reload
  end

  it "Category should be created for user" do
    c = @salkar.create_category :name => "test_cat_1"
    c.categoryable.should == @salkar
    c.name.should == "test_cat_1"
  end

  it "Category should be created for community" do
    c = @community.create_category :name => "test_cat_1"
    c.categoryable.should == @community
    c.name.should == "test_cat_1"
  end

  it "Category with parent cantegory should be created for user" do
    c = @salkar.create_category :name => "test_cat_0"
    c1 = @salkar.create_category :name => "test_cat_1", :parent_id => c.id
    c1.reload
    c.reload
    c1.categoryable.should == @salkar
    c1.ancestors.should == [c]
    c.reload
    c.descendants.should == [c1]
    c2 = @salkar.create_category :name => "test_cat_2", :parent_category_id => c1.id
    c.reload
    c1.reload
    c2.reload
    c.ancestors.should == []
    c1.ancestors.should == [c]
    c2.ancestors.should == [c,c1]
    c.descendants.should == [c1,c2]
    c1.descendants.should == [c2]
    c2.descendants.should == []
  end

  it "Category with parent cantegory should be created for community" do
    c = @community.create_category :name => "test_cat_0"
    c1 = @community.create_category :name => "test_cat_1", :parent_id => c.id
    c1.reload
    c.reload
    c1.categoryable.should == @community
    c1.ancestors.should == [c]
    c.reload
    c.descendants.should == [c1]
    c2 = @community.create_category :name => "test_cat_2", :parent_category_id => c1.id
    c.reload
    c1.reload
    c2.reload
    c.ancestors.should == []
    c1.ancestors.should == [c]
    c2.ancestors.should == [c, c1]
    c.descendants.should == [c1, c2]
    c1.descendants.should == [c2]
    c2.descendants.should == []
  end

  it "Category should be destroyed" do
    c = @community.create_category :name => "test_cat_0"
    c.destroy
    Category.where(:name => "test_cat_0").should == []

    c = @salkar.create_category :name => "test_cat_0"
    c.destroy
    Category.where(:name => "test_cat_0").should == []
  end

  it "Category info should be destroed recursively for community" do
    c = @community.create_category :name => "test_cat_0"
    c1 = @community.create_category :name => "test_cat_1", :parent_category_id => c.id
    c2 = @community.create_category :name => "test_cat_2", :parent_category_id => c1.id
    c.reload
    c1.reload
    c2.reload
    c.descendants.should == [c1,c2]
    c1.descendants.should == [c2]
    c2.ancestors.should == [c,c1]

    c2.destroy
    c.reload
    c1.reload
    c.descendants.should == [c1]
    c1.descendants.should == []
  end

  it "Category info should be destroed recursively for user" do
    c = @salkar.create_category :name => "test_cat_0"
    c1 = @salkar.create_category :name => "test_cat_1", :parent_category_id => c.id
    c2 = @salkar.create_category :name => "test_cat_2", :parent_category_id => c1.id
    c.reload
    c1.reload
    c2.reload
    c.descendants.should == [c1, c2]
    c1.descendants.should == [c2]
    c2.ancestors.should == [c, c1]

    c2.destroy
    c.reload
    c1.reload
    c.descendants.should == [c1]
    c1.descendants.should == []
  end

  it "Categories should be destroyed recursively for user" do
    c = @salkar.create_category :name => "test_cat_0"
    c1 = @salkar.create_category :name => "test_cat_1", :parent_category_id => c.id
    c2 = @salkar.create_category :name => "test_cat_2", :parent_category_id => c1.id
    Category.all.size.should == 3
    c.reload
    c1.reload
    c2.reload

    c1.destroy
    c.reload
    c.descendants.should == []
    Category.where(:name => "test_cat_2").should == []
    Category.all.size.should == 1
  end

  it "Categories should be destroyed recursively for community" do
    c = @community.create_category :name => "test_cat_0"
    c1 = @community.create_category :name => "test_cat_1", :parent_category_id => c.id
    c2 = @community.create_category :name => "test_cat_2", :parent_category_id => c1.id
    Category.all.size.should == 3
    c.reload
    c1.reload
    c2.reload

    c1.destroy
    c.reload
    c.descendants.should == []
    Category.where(:name => "test_cat_2").should == []
    Category.all.size.should == 1
  end


  it "Categories should be returned for user (user wrapper)" do
    c0 = @salkar.create_category :name => "test_cat"
    c00 = @salkar.create_category :name => "test_cat_0", :parent_category_id => c0.id
    c000 = @salkar.create_category :name => "test_cat_00", :parent_category_id => c00.id
    c01 = @salkar.create_category :name => "test_cat_1", :parent_category_id => c0.id
    c010 = @salkar.create_category :name => "test_cat_00", :parent_category_id => c01.id
    c011 = @salkar.create_category :name => "test_cat_00", :parent_category_id => c01.id
    c0101 = @salkar.create_category :name => "test_cat_00", :parent_category_id => c010.id
    c1 = @salkar.create_category :name => "test_cat_c_1"
    c10 = @salkar.create_category :name => "test_cat_c_1_0", :parent_category_id => c1.id
    result = @salkar.get_categories
    result.size.should == 9
    result.select { |r| r.id == c0.id }[0].parent_category_id.should == nil
    result.select { |r| r.id == c00.id }[0].parent_category_id.should == c0.id
    result.select { |r| r.id == c000.id }[0].parent_category_id.should == c00.id
    result.select { |r| r.id == c01.id }[0].parent_category_id.should == c0.id
    result.select { |r| r.id == c010.id }[0].parent_category_id.should == c01.id
    result.select { |r| r.id == c011.id }[0].parent_category_id.should == c01.id
    result.select { |r| r.id == c0101.id }[0].parent_category_id.should == c010.id
    result.select { |r| r.id == c1.id }[0].parent_category_id.should == nil
    result.select { |r| r.id == c10.id }[0].parent_category_id.should == c1.id
  end

  it "Categories should be returned for community (community wrapper)" do
    c0 = @community.create_category :name => "test_cat"
    c00 = @community.create_category :name => "test_cat_0", :parent_category_id => c0.id
    c000 = @community.create_category :name => "test_cat_00", :parent_category_id => c00.id
    c01 = @community.create_category :name => "test_cat_1", :parent_category_id => c0.id
    c010 = @community.create_category :name => "test_cat_00", :parent_category_id => c01.id
    c011 = @community.create_category :name => "test_cat_00", :parent_category_id => c01.id
    c0101 = @community.create_category :name => "test_cat_00", :parent_category_id => c010.id
    c1 = @community.create_category :name => "test_cat_c_1"
    c10 = @community.create_category :name => "test_cat_c_1_0", :parent_category_id => c1.id
    result = @community.get_categories
    result.size.should == 9
    result.select { |r| r.id == c0.id }[0].parent_category_id.should == nil
    result.select { |r| r.id == c00.id }[0].parent_category_id.should == c0.id
    result.select { |r| r.id == c000.id }[0].parent_category_id.should == c00.id
    result.select { |r| r.id == c01.id }[0].parent_category_id.should == c0.id
    result.select { |r| r.id == c010.id }[0].parent_category_id.should == c01.id
    result.select { |r| r.id == c011.id }[0].parent_category_id.should == c01.id
    result.select { |r| r.id == c0101.id }[0].parent_category_id.should == c010.id
    result.select { |r| r.id == c1.id }[0].parent_category_id.should == nil
    result.select { |r| r.id == c10.id }[0].parent_category_id.should == c1.id
  end

  it "Post should be added to category by user" do
    c = @salkar.create_category :name => "test_cat"
    blog_item = ::Inkwell::BlogItem.where(:owner_id => @salkar.id, :owner_type => 'u', :item_id => @salkar_post.id, :item_type => 'p').first
    c.add_item :item => @salkar_post, :owner => @salkar
    records = ::Inkwell::BlogItemCategory.where :category_id => c.id
    records.size.should == 1
    records.first.blog_item_created_at.should be
    records.first.blog_item_id.should == blog_item.id
    records.first.category_id.should == c.id
  end

  it "Comment should be added to category by user" do
    @spy_comment = @spy.create_comment :for_object => @salkar_post, :body => "comment body"
    @salkar.reblog @spy_comment
    c = @salkar.create_category :name => "test_cat"
    blog_item = ::Inkwell::BlogItem.where(:owner_id => @salkar.id, :owner_type => 'u', :item_id => @spy_comment.id, :item_type => 'c').first
    c.add_item :item => @spy_comment, :owner => @salkar
    records = ::Inkwell::BlogItemCategory.where :category_id => c.id
    records.size.should == 1
    records.first.blog_item_created_at.should be
    records.first.blog_item_id.should == blog_item.id
    records.first.category_id.should == c.id
  end

  it "Post should be added to category by community" do
    c = @community.create_category :name => "test_cat"
    @salkar.join @community
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community
    blog_item = ::Inkwell::BlogItem.where(:owner_id => @community.id, :owner_type => 'c', :item_id => @salkar_post.id, :item_type => 'p').first
    c.add_item :item => @salkar_post, :owner => @community
    records = ::Inkwell::BlogItemCategory.where :category_id => c.id
    records.size.should == 1
    records.first.blog_item_created_at.should be
    records.first.blog_item_id.should == blog_item.id
    records.first.category_id.should == c.id
  end

  it "Post should be removed from category by user" do
    c = @salkar.create_category :name => "test_cat"
    c.add_item :item => @salkar_post, :owner => @salkar
    c.remove_item :item => @salkar_post, :owner => @salkar
    records = ::Inkwell::BlogItemCategory.where :category_id => c.id
    records.size.should == 0
  end

  it "Comment should be removed from category by user" do
    @spy_comment = @spy.create_comment :for_object => @salkar_post, :body => "comment body"
    @salkar.reblog @spy_comment
    c = @salkar.create_category :name => "test_cat"
    c.add_item :item => @spy_comment, :owner => @salkar
    c.remove_item :item => @spy_comment, :owner => @salkar
    records = ::Inkwell::BlogItemCategory.where :category_id => c.id
    records.size.should == 0
  end

  it "Post should be removed from category by community" do
    c = @community.create_category :name => "test_cat"
    @salkar.join @community
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community
    c.add_item :item => @salkar_post, :owner => @community
    c.remove_item :item => @salkar_post, :owner => @community
    records = ::Inkwell::BlogItemCategory.where :category_id => c.id
    records.size.should == 0
  end

  it "Category blogline should be returned for user" do
    c = @salkar.create_category :name => "test_cat"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    @comment = @morozovm.create_comment :for_object => @morozovm_post, :body => "salkar_comment_body"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body4"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body5"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body6"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body7"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body8"
    @salkar.reblog @morozovm_post
    @salkar.reblog @morozovm_post1
    @salkar.reblog @morozovm_post2
    @salkar.reblog @comment
    @salkar_post9 = @salkar.posts.create :body => "salkar_post_test_body9"
    @salkar_post10 = @salkar.posts.create :body => "salkar_post_test_body10"
    c.add_item :item => @salkar_post, :owner => @salkar
    c.add_item :item => @salkar_post1, :owner => @salkar
    c.add_item :item => @salkar_post2, :owner => @salkar
    c.add_item :item => @salkar_post3, :owner => @salkar
    c.add_item :item => @salkar_post4, :owner => @salkar
    c.add_item :item => @salkar_post5, :owner => @salkar
    c.add_item :item => @salkar_post7, :owner => @salkar
    c.add_item :item => @salkar_post8, :owner => @salkar
    c.add_item :item => @salkar_post9, :owner => @salkar
    c.add_item :item => @salkar_post10, :owner => @salkar
    c.add_item :item => @morozovm_post1, :owner => @salkar
    c.add_item :item => @morozovm_post, :owner => @salkar
    c.add_item :item => @comment, :owner => @salkar

    bline = @salkar.blogline :category => c
    bline.size.should == 10
    bline[0].should == @salkar_post10
    bline[1].should == @salkar_post9
    bline[2].should == @comment
    bline[3].should == @morozovm_post1
    bline[4].should == @morozovm_post
    bline[5].should == @salkar_post8
    bline[6].should == @salkar_post7
    bline[7].should == @salkar_post5
    bline[8].should == @salkar_post4
    bline[9].should == @salkar_post3
  end

  it "Category blogline should be returned for user with offset" do
    c = @salkar.create_category :name => "test_cat"
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    @comment = @morozovm.create_comment :for_object => @morozovm_post, :body => "salkar_comment_body"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body4"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body5"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body6"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body7"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body8"
    @salkar.reblog @morozovm_post
    @salkar.reblog @morozovm_post1
    @salkar.reblog @morozovm_post2
    @salkar.reblog @comment
    @salkar_post9 = @salkar.posts.create :body => "salkar_post_test_body9"
    @salkar_post10 = @salkar.posts.create :body => "salkar_post_test_body10"
    c.add_item :item => @salkar_post, :owner => @salkar
    c.add_item :item => @salkar_post1, :owner => @salkar
    c.add_item :item => @salkar_post2, :owner => @salkar
    c.add_item :item => @salkar_post3, :owner => @salkar
    c.add_item :item => @salkar_post4, :owner => @salkar
    c.add_item :item => @salkar_post5, :owner => @salkar
    c.add_item :item => @salkar_post7, :owner => @salkar
    c.add_item :item => @salkar_post8, :owner => @salkar
    c.add_item :item => @salkar_post9, :owner => @salkar
    c.add_item :item => @salkar_post10, :owner => @salkar
    c.add_item :item => @morozovm_post1, :owner => @salkar
    c.add_item :item => @morozovm_post, :owner => @salkar
    c.add_item :item => @comment, :owner => @salkar

    bline = @salkar.blogline :category => c, :last_shown_obj_id => ::Inkwell::BlogItem.where(:owner_id => @salkar.id, :owner_type => 'u',
                                                                                             :item_id => @salkar_post9.id, :item_type => 'p').first.id
    bline.size.should == 10
    bline[0].should == @comment
    bline[1].should == @morozovm_post1
    bline[2].should == @morozovm_post
    bline[3].should == @salkar_post8
    bline[4].should == @salkar_post7
    bline[5].should == @salkar_post5
    bline[6].should == @salkar_post4
    bline[7].should == @salkar_post3
    bline[8].should == @salkar_post2
    bline[9].should == @salkar_post1
  end

  it "Category blogline should be returned for user" do
    c = @salkar.create_category :name => "test_cat"
    c.reload
    c1 = @salkar.create_category :name => "test_cat_2", :parent_category_id => c.id
    c.reload
    c1.reload
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    @comment = @morozovm.create_comment :for_object => @morozovm_post, :body => "salkar_comment_body"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body4"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body5"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body6"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body7"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body8"
    @salkar.reblog @morozovm_post
    @salkar.reblog @morozovm_post1
    @salkar.reblog @morozovm_post2
    @salkar.reblog @comment
    @salkar_post9 = @salkar.posts.create :body => "salkar_post_test_body9"
    @salkar_post10 = @salkar.posts.create :body => "salkar_post_test_body10"
    c.add_item :item => @salkar_post, :owner => @salkar
    c1.add_item :item => @salkar_post1, :owner => @salkar
    c.add_item :item => @salkar_post2, :owner => @salkar
    c1.add_item :item => @salkar_post3, :owner => @salkar
    c.add_item :item => @salkar_post4, :owner => @salkar
    c.add_item :item => @salkar_post5, :owner => @salkar
    c1.add_item :item => @salkar_post7, :owner => @salkar
    c.add_item :item => @salkar_post8, :owner => @salkar
    c.add_item :item => @salkar_post9, :owner => @salkar
    c1.add_item :item => @salkar_post10, :owner => @salkar
    c.add_item :item => @morozovm_post1, :owner => @salkar
    c1.add_item :item => @morozovm_post, :owner => @salkar
    c.add_item :item => @comment, :owner => @salkar

    bline = @salkar.blogline :category => c
    bline.size.should == 10
    bline[0].should == @salkar_post10
    bline[1].should == @salkar_post9
    bline[2].should == @comment
    bline[3].should == @morozovm_post1
    bline[4].should == @morozovm_post
    bline[5].should == @salkar_post8
    bline[6].should == @salkar_post7
    bline[7].should == @salkar_post5
    bline[8].should == @salkar_post4
    bline[9].should == @salkar_post3
  end

  it "Category blogline should be returned for community" do
    c = @community.create_category :name => "test_cat"
    @salkar.join @community
    @morozovm.join @community
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body4"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body5"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body6"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body7"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body8"
    @salkar.send_post_to_community :post => @salkar_post1, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post2, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post3, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post4, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post5, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post6, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post7, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post8, :to_community => @community
    @morozovm.send_post_to_community :post => @morozovm_post, :to_community => @community
    @morozovm.send_post_to_community :post => @morozovm_post1, :to_community => @community
    @morozovm.send_post_to_community :post => @morozovm_post2, :to_community => @community
    @salkar_post9 = @salkar.posts.create :body => "salkar_post_test_body9"
    @salkar_post10 = @salkar.posts.create :body => "salkar_post_test_body10"
    @salkar.send_post_to_community :post => @salkar_post9, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post10, :to_community => @community

    c.add_item :item => @salkar_post1, :owner => @community
    c.add_item :item => @salkar_post2, :owner => @community
    c.add_item :item => @salkar_post3, :owner => @community
    c.add_item :item => @salkar_post4, :owner => @community
    c.add_item :item => @salkar_post5, :owner => @community
    c.add_item :item => @salkar_post7, :owner => @community
    c.add_item :item => @salkar_post8, :owner => @community
    c.add_item :item => @salkar_post9, :owner => @community
    c.add_item :item => @salkar_post10, :owner => @community
    c.add_item :item => @morozovm_post1, :owner => @community
    c.add_item :item => @morozovm_post, :owner => @community

    bline = @community.blogline :category => c
    bline.size.should == 10
    bline[0].should == @salkar_post10
    bline[1].should == @salkar_post9
    bline[2].should == @morozovm_post1
    bline[3].should == @morozovm_post
    bline[4].should == @salkar_post8
    bline[5].should == @salkar_post7
    bline[6].should == @salkar_post5
    bline[7].should == @salkar_post4
    bline[8].should == @salkar_post3
    bline[9].should == @salkar_post2
  end

  it "Category blogline should be returned for community with offset" do
    c = @community.create_category :name => "test_cat"
    @salkar.join @community
    @morozovm.join @community
    @morozovm_post = @morozovm.posts.create :body => "morozovm_post_test_body"
    @morozovm_post1 = @morozovm.posts.create :body => "morozovm_post_test_body1"
    @morozovm_post2 = @morozovm.posts.create :body => "morozovm_post_test_body2"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body1"
    @salkar_post2 = @salkar.posts.create :body => "salkar_post_test_body2"
    @salkar_post3 = @salkar.posts.create :body => "salkar_post_test_body3"
    @salkar_post4 = @salkar.posts.create :body => "salkar_post_test_body4"
    @salkar_post5 = @salkar.posts.create :body => "salkar_post_test_body5"
    @salkar_post6 = @salkar.posts.create :body => "salkar_post_test_body6"
    @salkar_post7 = @salkar.posts.create :body => "salkar_post_test_body7"
    @salkar_post8 = @salkar.posts.create :body => "salkar_post_test_body8"
    @salkar.send_post_to_community :post => @salkar_post1, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post2, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post3, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post4, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post5, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post6, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post7, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post8, :to_community => @community
    @morozovm.send_post_to_community :post => @morozovm_post, :to_community => @community
    @morozovm.send_post_to_community :post => @morozovm_post1, :to_community => @community
    @morozovm.send_post_to_community :post => @morozovm_post2, :to_community => @community
    @salkar_post9 = @salkar.posts.create :body => "salkar_post_test_body9"
    @salkar_post10 = @salkar.posts.create :body => "salkar_post_test_body10"
    @salkar.send_post_to_community :post => @salkar_post9, :to_community => @community
    @salkar.send_post_to_community :post => @salkar_post10, :to_community => @community

    c.add_item :item => @salkar_post1, :owner => @community
    c.add_item :item => @salkar_post2, :owner => @community
    c.add_item :item => @salkar_post3, :owner => @community
    c.add_item :item => @salkar_post4, :owner => @community
    c.add_item :item => @salkar_post5, :owner => @community
    c.add_item :item => @salkar_post7, :owner => @community
    c.add_item :item => @salkar_post8, :owner => @community
    c.add_item :item => @salkar_post9, :owner => @community
    c.add_item :item => @salkar_post10, :owner => @community
    c.add_item :item => @morozovm_post1, :owner => @community
    c.add_item :item => @morozovm_post, :owner => @community

    bline = @community.blogline :category => c, :last_shown_obj_id => ::Inkwell::BlogItem.where(:owner_id => @community.id, :owner_type => 'c',
                                                                                                 :item_id => @salkar_post9.id, :item_type => 'p').first.id
    bline.size.should == 9
    bline[0].should == @morozovm_post1
    bline[1].should == @morozovm_post
    bline[2].should == @salkar_post8
    bline[3].should == @salkar_post7
    bline[4].should == @salkar_post5
    bline[5].should == @salkar_post4
    bline[6].should == @salkar_post3
    bline[7].should == @salkar_post2
    bline[8].should == @salkar_post1
  end

  it "Categories blogline records should be deleted when category is deleted" do
    c = @salkar.create_category :name => "test_cat"
    id = c.id
    c.add_item :item => @salkar_post, :owner => @salkar
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 1
    c.destroy
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 0
  end

  it "Child categories blogline records should be deleted when category is deleted" do
    c = @salkar.create_category :name => "test_cat"
    c1 = @salkar.create_category :name => "test_cat", :parent_category_id => c.id
    id = c1.id
    c1.add_item :item => @salkar_post, :owner => @salkar
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 1
    c.reload
    c.destroy
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 0
  end

  it "User's categories should be deleted when user is deleted" do
    c = @salkar.create_category :name => "test_cat"
    c1 = @salkar.create_category :name => "test_cat", :parent_category_id => c.id
    @salkar.categories.size.should == 2
    @salkar.destroy
    Category.all.size.should == 0
  end

  it "Child categories blogline records should be deleted when user is deleted" do
    c = @salkar.create_category :name => "test_cat"
    c1 = @salkar.create_category :name => "test_cat", :parent_category_id => c.id
    id = c1.id
    c1.add_item :item => @salkar_post, :owner => @salkar
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 1
    c.reload
    @salkar.destroy
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 0
  end

  it "Community's categories should be deleted when community is deleted" do
    c = @community.create_category :name => "test_cat"
    c1 = @community.create_category :name => "test_cat", :parent_category_id => c.id
    id = @community.id
    @community.categories.size.should == 2
    @community.destroy
    Category.all.size.should == 0
  end

  it "Child categories blogline records should be deleted when community is deleted" do
    c = @community.create_category :name => "test_cat"
    c1 = @community.create_category :name => "test_cat", :parent_category_id => c.id
    id = c1.id
    @salkar.join @community
    @salkar.send_post_to_community :post => @salkar_post, :to_community => @community
    c1.add_item :item => @salkar_post, :owner => @community
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 1
    c.reload
    @community.destroy
    ::Inkwell::BlogItemCategory.where(:category_id => id).size.should == 0
  end

  it "Categories blogline records should be deleted when post is deleted" do
    c = @salkar.create_category :name => "test_cat"
    @spy_comment = @spy.create_comment :for_object => @salkar_post, :body => "comment body"
    @salkar.reblog @spy_comment
    c.add_item :item => @spy_comment, :owner => @salkar
    c.add_item :item => @salkar_post, :owner => @salkar
    ::Inkwell::BlogItemCategory.where(:category_id => c.id).size.should == 2
    @salkar_post.destroy
    ::Inkwell::BlogItemCategory.where(:category_id => c.id).size.should == 0
  end

  it "Categories blogline records should be deleted when comment is deleted" do
    c = @salkar.create_category :name => "test_cat"
    @spy_comment = @spy.create_comment :for_object => @salkar_post, :body => "comment body"
    @morozovm_comment = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @spy_comment.id)
    @spy_comment.reload
    @salkar.reblog @spy_comment
    @salkar.reblog @morozovm_comment
    c.add_item :item => @morozovm_comment, :owner => @salkar
    c.add_item :item => @spy_comment, :owner => @salkar
    ::Inkwell::BlogItemCategory.where(:category_id => c.id).size.should == 2
    @spy_comment.destroy
    ::Inkwell::BlogItemCategory.where(:category_id => c.id).size.should == 0
  end

end
