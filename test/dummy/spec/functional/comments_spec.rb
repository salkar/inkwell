require "spec_helper"

describe "Comments" do

  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
  end

  it "comments should be available for user and post" do
    @salkar.comments.should == []
    @salkar_post.comments.should == []
  end

  it "comment should been created" do
    @salkar.comments.size.should == 0
    comment = @salkar.comments.create :post_id => @salkar_post.id, :body => "salkar_comment_body"
    @salkar.comments.size.should == 1
    @salkar_post.comments.size.should == 1
    @salkar.comments.should == @salkar_post.comments
    comment.id.should be
    comment.body.should be
    comment.user.should == @salkar
    comment.post.should == @salkar_post
    comment.users_ids_who_favorite_it.should == "[]"
    comment.users_ids_who_comment_it.should == "[]"
    comment.users_ids_who_reblog_it.should == "[]"

    @salkar_post = Post.find @salkar_post
    ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it).should == [{"user_id"=>@salkar.id, "comment_id"=>comment.id}]
  end

  it "comment should not been created" do
    post = @salkar.comments.create :post_id => @salkar_post.id
    post.id.should == nil
    post = @salkar.comments.create :body => "salkar_comment_body"
    post.id.should == nil
    post = @salkar_post.comments.create :body => "salkar_comment_body"
    post.id.should == nil
  end

  it "10 comments for main post should been received" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment3 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment4 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment5 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment6 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment7 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment8 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment9 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment10 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment11 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)

    commentline = @salkar_post.commentline
    commentline.size.should == 10
    commentline[0].id.should == @comment2.id
    commentline[9].id.should == @comment11.id

    commentline = @salkar_post.commentline :last_shown_comment_id => @comment10.id
    commentline.size.should == 10
    commentline[0].id.should == @comment.id
    commentline[9].id.should == @comment9.id

  end

  it "5 comments for main post should been received" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment3 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment1.id)
    @comment4 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment5 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment6 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment7 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment8 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment9 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment10 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment11 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)

    commentline = @salkar_post.commentline :limit => 5
    commentline.size.should == 5
    commentline[0].id.should == @comment7.id
    commentline[4].id.should == @comment11.id

    commentline = @salkar_post.commentline :last_shown_comment_id => @comment10.id, :limit => 5
    commentline.size.should == 5
    commentline[0].id.should == @comment5.id
    commentline[4].id.should == @comment9.id

    commentline = @salkar_post.commentline :last_shown_comment_id => @comment5.id, :limit => 7
    commentline.size.should == 5
    commentline[0].id.should == @comment.id
    commentline[4].id.should == @comment4.id
  end

  it "comments should been deleted when parent post destroyed" do
    @salkar_comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @morozovm_comment = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @salkar_post.comments.size.should == 2
    ::Inkwell::Comment.all.size.should == 2
    @salkar_post.destroy
    ::Inkwell::Comment.all.size.should == 0
  end

  it "2 comments with parent_id should been created" do
    @salkar_comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @morozovm_comment = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @salkar_comment.id)
    @salkar_comment = ::Inkwell::Comment.find @salkar_comment
    @morozovm_comment = ::Inkwell::Comment.find @morozovm_comment
    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_comment.users_ids_who_comment_it).should == [{"user_id"=>@morozovm.id, "comment_id"=>@morozovm_comment.id}]
    ActiveSupport::JSON.decode(@morozovm_comment.upper_comments_tree).should == [@salkar_comment.id]
    ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it).should == [{"user_id"=>@salkar.id, "comment_id"=>@salkar_comment.id}, {"user_id"=>@morozovm.id, "comment_id"=>@morozovm_comment.id}]


    ActiveSupport::JSON.decode(@morozovm_comment.users_ids_who_comment_it).should == []
    ActiveSupport::JSON.decode(@salkar_comment.upper_comments_tree).should == []
  end

  it "7 comments should been created" do
    @salkar_comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @morozovm_comment = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @salkar_comment.id)
    @salkar_comment1 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @morozovm_comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @salkar_comment.id)
    @salkar_comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @morozovm_comment2 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @salkar_comment.id)
    @salkar_comment3 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.size.should == 7
    users_ids_who_comment_it[0].should == {"user_id"=>@salkar.id, "comment_id"=>@salkar_comment.id}
    users_ids_who_comment_it[6].should == {"user_id"=>@salkar.id, "comment_id"=>@salkar_comment3.id}

    @salkar_comment.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_comment.users_ids_who_comment_it)
    users_ids_who_comment_it.size.should == 3
    users_ids_who_comment_it[0].should == {"user_id"=>@morozovm.id, "comment_id"=>@morozovm_comment.id}
    users_ids_who_comment_it[2].should == {"user_id"=>@morozovm.id, "comment_id"=>@morozovm_comment2.id}

    @salkar_comment1.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_comment1.users_ids_who_comment_it)
    users_ids_who_comment_it.size.should == 0

    @salkar_comment3.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_comment3.users_ids_who_comment_it)
    users_ids_who_comment_it.size.should == 0
  end

  it "1 comments should been deleted from post" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == [{"user_id"=>@salkar.id, "comment_id"=>@comment.id}]
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :user_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :user_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @morozovm.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.all.size.should == 1
    ::Inkwell::TimelineItem.all.size.should == 1
    ::Inkwell::BlogItem.all.size.should == 3
    ::Inkwell::Comment.all.size.should == 1

    @comment.destroy
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == []
    ::Inkwell::FavoriteItem.all.size.should == 0
    ::Inkwell::TimelineItem.all.size.should == 0
    ::Inkwell::BlogItem.all.size.should == 1
    ::Inkwell::Comment.all.size.should == 0
  end

  it "1 comments should been deleted from post with parent comment" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment_to_delete = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == [{"user_id" => @salkar.id, "comment_id" => @comment.id}, {"user_id" => @morozovm.id, "comment_id" => @comment_to_delete.id}]
    ::Inkwell::TimelineItem.create :item_id => @comment_to_delete.id, :user_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.create :item_id => @comment_to_delete.id, :user_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :user_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :user_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment_to_delete.id, :owner_id => @morozovm.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment_to_delete.id, :owner_id => @salkar.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.all.size.should == 2
    ::Inkwell::TimelineItem.all.size.should == 2
    ::Inkwell::BlogItem.all.size.should == 4
    ::Inkwell::Comment.all.size.should == 2

    @comment_to_delete.destroy
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == [{"user_id" => @salkar.id, "comment_id" => @comment.id}]
    ::Inkwell::FavoriteItem.all.size.should == 1
    ::Inkwell::TimelineItem.all.size.should == 1
    ::Inkwell::BlogItem.all.size.should == 2
    ::Inkwell::Comment.all.size.should == 1
    @comment.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@comment.users_ids_who_comment_it)
    users_ids_who_comment_it.should == []
  end

  it "2 comments should been deleted from post with parent comment" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment2 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == [{"user_id" => @salkar.id, "comment_id" => @comment.id}, {"user_id" => @morozovm.id, "comment_id" => @comment2.id}]
    ::Inkwell::TimelineItem.create :item_id => @comment2.id, :user_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.create :item_id => @comment2.id, :user_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :user_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :user_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.all.size.should == 2
    ::Inkwell::TimelineItem.all.size.should == 2
    ::Inkwell::BlogItem.all.size.should == 4
    ::Inkwell::Comment.all.size.should == 2
    @comment.reload

    @comment.destroy
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == []
    ::Inkwell::FavoriteItem.all.size.should == 0
    ::Inkwell::TimelineItem.all.size.should == 0
    ::Inkwell::BlogItem.all.size.should == 1
    ::Inkwell::Comment.all.size.should == 0
  end

  it "4 comments should been deleted from post with parent comment" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment2 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment2.id)
    @comment3 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.size.should == 4
    ::Inkwell::TimelineItem.create :item_id => @comment2.id, :user_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.create :item_id => @comment2.id, :user_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :user_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :user_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @morozovm.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @salkar.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :is_owner_user => true, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT
    ::Inkwell::FavoriteItem.all.size.should == 2
    ::Inkwell::TimelineItem.all.size.should == 2
    ::Inkwell::BlogItem.all.size.should == 4
    ::Inkwell::Comment.all.size.should == 4
    @comment.reload

    @comment.destroy
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == []
    ::Inkwell::FavoriteItem.all.size.should == 0
    ::Inkwell::TimelineItem.all.size.should == 0
    ::Inkwell::BlogItem.all.size.should == 1
    ::Inkwell::Comment.all.size.should == 0
  end

  it "commentline for comment should been returned (comments for 1 comment)" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment3 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment4 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment5 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment6 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment7 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment8 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment9 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment10 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment11 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)

    @comment.reload
    commentline = @comment.commentline
    commentline.size.should == 10
    commentline[0].id.should == @comment2.id
    commentline[9].id.should == @comment11.id

    commentline = @salkar_post.commentline :last_shown_comment_id => @comment10.id
    commentline.size.should == 10
    commentline[0].id.should == @comment.id
    commentline[9].id.should == @comment9.id
  end

  it "commentline for comment should been returned (comments for several comments)" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment3 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment1.id)
    @comment4 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment2.id)
    @comment5 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment6 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment3.id)
    @comment7 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment2.id)
    @comment8 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment9 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment5.id)
    @comment10 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment4.id)
    @comment11 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)

    @comment.reload
    commentline = @comment.commentline
    commentline.size.should == 10
    commentline[0].id.should == @comment2.id
    commentline[9].id.should == @comment11.id

    commentline = @salkar_post.commentline :last_shown_comment_id => @comment10.id
    commentline.size.should == 10
    commentline[0].id.should == @comment.id
    commentline[9].id.should == @comment9.id
  end

  it "5 comments for comment should been received" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment3 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment1.id)
    @comment4 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment2.id)
    @comment5 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment6 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment3.id)
    @comment7 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment2.id)
    @comment8 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment9 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment5.id)
    @comment10 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment4.id)
    @comment11 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)

    @comment.reload
    commentline = @comment.commentline :limit => 5
    commentline.size.should == 5
    commentline[0].id.should == @comment7.id
    commentline[4].id.should == @comment11.id

    @comment.reload
    commentline = @comment.commentline :last_shown_comment_id => @comment10.id, :limit => 5
    commentline.size.should == 5
    commentline[0].id.should == @comment5.id
    commentline[4].id.should == @comment9.id

    @comment.reload
    commentline = @comment.commentline :last_shown_comment_id => @comment5.id, :limit => 7
    commentline.size.should == 4
    commentline[0].id.should == @comment1.id
    commentline[3].id.should == @comment4.id
  end

  it "is_favorited should been returned in commentline for comment for for_user" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @salkar.favorite @comment1
    @morozovm.favorite @comment2

    @comment.reload
    commentline = @comment.commentline :for_user => @salkar
    commentline[0].id.should == @comment1.id
    commentline[0].is_favorited.should == true
    commentline[1].id.should == @comment2.id
    commentline[1].is_favorited.should == false

    commentline = @comment.commentline :for_user => @morozovm
    commentline[0].id.should == @comment1.id
    commentline[0].is_favorited.should == false
    commentline[1].id.should == @comment2.id
    commentline[1].is_favorited.should == true
  end

  it "is_favorited should been returned in commentline for post for for_user" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @salkar.favorite @comment1
    @morozovm.favorite @comment2

    @salkar_post.reload
    commentline = @salkar_post.commentline :for_user => @salkar
    commentline[1].id.should == @comment1.id
    commentline[1].is_favorited.should == true
    commentline[2].id.should == @comment2.id
    commentline[2].is_favorited.should == false

    commentline = @salkar_post.commentline :for_user => @morozovm
    commentline[1].id.should == @comment1.id
    commentline[1].is_favorited.should == false
    commentline[2].id.should == @comment2.id
    commentline[2].is_favorited.should == true
  end

  it "comment count for post should been received" do
    @salkar_post.comments.size.should == 0
    @salkar_post.comment_count.should == 0
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @salkar_post.reload
    @salkar_post.comments.size.should == 3
    @salkar_post.comment_count.should == 3
  end

  it "comment count for comment should been received" do
    @comment = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id)
    @comment.reload
    @comment.comment_count.should == 0
    @comment1 = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment2 = @salkar.comments.create(:body => 'Lets You Party Like a Facebook User', :post_id => @salkar_post.id, :parent_id => @comment.id)
    @comment.reload
    @comment.comment_count.should == 2
  end


end