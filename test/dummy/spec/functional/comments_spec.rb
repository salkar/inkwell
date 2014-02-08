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
    comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @salkar.reload
    @salkar.comments.size.should == 1
    comment_1 = @salkar_post.comments.create user_id:@salkar.id, body:'comment_body 2'
    @salkar.reload
    @salkar.comments.size.should == 2
    @salkar_post.reload
    @salkar_post.comments.size.should == 2
    comment.user.should == @salkar
    comment_1.user.should == @salkar
    comment.body.should == 'comment_body'
    comment_1.body.should == 'comment_body 2'
    comment.commentable.should == @salkar_post
    comment_1.commentable.should == @salkar_post

    @salkar_post.reload
    ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it).should == [{"user_id"=>@salkar.id, "comment_id"=>comment.id}, {"user_id"=>@salkar.id, "comment_id"=>comment_1.id}]
  end


  it "10 comments for main post should been received" do
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment1 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment2 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment3 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment4 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment5 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment6 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment7 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment8 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment9 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment10 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment11 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'

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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment1 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment2 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment3 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body', :parent_id => @comment1.id
    @comment4 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment5 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment6 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment7 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment8 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment9 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @comment10 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment11 = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'

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
    @salkar_comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @morozovm_comment = @morozovm.comments.create commentable:@salkar_post, body:'comment_body'
    @salkar_post.comments.size.should == 2
    ::Inkwell::Comment.all.size.should == 2
    @salkar_post.destroy
    ::Inkwell::Comment.all.size.should == 0
  end

  it "2 comments with parent_id should been created" do
    @salkar_comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @morozovm_comment = @morozovm.comments.create(:body => 'Lets You Party Like a Facebook User', :commentable => @salkar_post, :parent_id => @salkar_comment.id)
    @salkar_comment.reload
    @morozovm_comment.reload
    @salkar_post.reload
    @salkar_comment.children.should == [@morozovm_comment]
    @salkar_comment.ancestors.should == []
    @morozovm_comment.children.should == []
    @morozovm_comment.ancestors.should == [@salkar_comment]
  end

  it "7 comments should been created" do
    @salkar_comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @morozovm_comment = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @salkar_comment.id)
    @salkar_post.reload
    @salkar_comment1 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @morozovm_comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @salkar_comment.id)
    @salkar_post.reload
    @salkar_comment2 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @morozovm_comment2 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @salkar_comment.id)
    @salkar_post.reload
    @salkar_comment3 = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.size.should == 7
    users_ids_who_comment_it[0].should == {"user_id"=>@salkar.id, "comment_id"=>@salkar_comment.id}
    users_ids_who_comment_it[6].should == {"user_id"=>@salkar.id, "comment_id"=>@salkar_comment3.id}

    @salkar_comment.reload
    @salkar_comment.children.size.should == 3
    @salkar_comment.ancestors.should == []

    @salkar_comment1.reload
    @salkar_comment1.children.size.should == 0
    @salkar_comment1.ancestors.should == []
  end

  it "1 comments should been deleted from post" do
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == [{"user_id"=>@salkar.id, "comment_id"=>@comment.id}]
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment_to_delete = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == [{"user_id" => @salkar.id, "comment_id" => @comment.id}, {"user_id" => @morozovm.id, "comment_id" => @comment_to_delete.id}]
    ::Inkwell::TimelineItem.create :item_id => @comment_to_delete.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.create :item_id => @comment_to_delete.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment_to_delete.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment_to_delete.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
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
    @comment.comment_count.should == 0
  end

  it "2 comments should been deleted from post with parent comment" do
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment2 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment.reload
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.should == [{"user_id" => @salkar.id, "comment_id" => @comment.id}, {"user_id" => @morozovm.id, "comment_id" => @comment2.id}]
    ::Inkwell::TimelineItem.create :item_id => @comment2.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.create :item_id => @comment2.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.all.size.should == 2
    ::Inkwell::TimelineItem.all.size.should == 2
    ::Inkwell::BlogItem.all.size.should == 4
    ::Inkwell::Comment.all.size.should == 2
    @comment.reload
    @salkar_post.reload
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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment2 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment3 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment2.id)
    @comment4 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @salkar_post.reload
    users_ids_who_comment_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_comment_it)
    users_ids_who_comment_it.size.should == 4
    ::Inkwell::TimelineItem.create :item_id => @comment2.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.create :item_id => @comment2.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::TimelineItem.create :item_id => @comment.id, :owner_id => @morozovm.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @morozovm.id,  :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment2.id, :owner_id => @salkar.id,  :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::BlogItem.create :item_id => @comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @salkar_post.reload
    @comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @salkar_post.reload
    @comment2 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment3 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment4 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment5 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment6 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment7 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment8 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment9 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment10 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment11 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)

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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment2 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment3 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment1.id)
    @comment4 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment2.id)
    @comment5 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment6 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment3.id)
    @comment7 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment2.id)
    @comment8 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment9 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment5.id)
    @comment10 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment4.id)
    @comment11 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)

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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment2 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment3 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment1.id)
    @comment4 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment2.id)
    @comment5 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment6 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment3.id)
    @comment7 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment2.id)
    @comment8 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment9 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment5.id)
    @comment10 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment4.id)
    @comment11 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)

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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment2 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment2 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
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
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment2 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @salkar_post.reload
    @salkar_post.comments.size.should == 3
    @salkar_post.comment_count.should == 3
  end

  it "comment count for comment should been received" do
    @comment = @salkar.comments.create commentable:@salkar_post, body:'comment_body'
    @comment.reload
    @comment.comment_count.should == 0
    @comment1 = @morozovm.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment2 = @salkar.create_comment(:body => 'Lets You Party Like a Facebook User', :for_object => @salkar_post, :parent_comment_id => @comment.id)
    @comment.reload
    @comment.comment_count.should == 2
  end


end