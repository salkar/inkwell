require "spec_helper"

describe "Favorites" do

  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.comments.create :post_id => @salkar_post.id, :body => "salkar_comment_body"
  end

  it "Post should been favorited" do
    @salkar.favorite @salkar_post
  end

  it "Comment should been favorited" do
    @salkar.favorite @salkar_comment
  end

  it "String should not been favorited" do
    expect{@salkar.favorite "string"}.to raise_error
  end

  it "Post should been favorited" do
    ::Inkwell::FavoriteItem.create :item_id => @salkar_post.id, :user_id => @salkar.id, :is_comment => false
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar.favorite?(@salkar_post).should == true
  end

  it "Post should not been favorited" do
    ::Inkwell::FavoriteItem.all.size.should == 0
    @salkar.favorite?(@salkar_post).should == false
  end

  it "Comment should been favorited" do
    ::Inkwell::FavoriteItem.create :item_id => @salkar_comment.id, :user_id => @salkar.id, :is_comment => true
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar.favorite?(@salkar_comment).should == true
  end

  it "Comment should not been favorited" do
    ::Inkwell::FavoriteItem.all.size.should == 0
    @salkar.favorite?(@salkar_comment).should == false
  end

  it "User should favorite post" do
    @salkar.favorite @salkar_post
    @salkar.favorite?(@salkar_post).should == true
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar_post.reload
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == [@salkar.id]
    @morozovm.favorite @salkar_post
    @morozovm.favorite?(@salkar_post).should == true
    ::Inkwell::FavoriteItem.all.size.should == 2
    @salkar_post.reload
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == [@salkar.id, @morozovm.id]
  end

  it "User should favorite comment" do
    @salkar.favorite @salkar_comment
    @salkar.favorite?(@salkar_comment).should == true
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar_comment.reload
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_comment.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == [@salkar.id]
    @morozovm.favorite @salkar_comment
    @morozovm.favorite?(@salkar_comment).should == true
    ::Inkwell::FavoriteItem.all.size.should == 2
    @salkar_comment.reload
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_comment.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == [@salkar.id, @morozovm.id]
  end

  it "User should unfavorite post" do
    @salkar.favorite @salkar_post
    @salkar_post.reload
    @salkar.unfavorite @salkar_post
    @salkar_post.reload
    ::Inkwell::FavoriteItem.all.size.should == 0
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == []

    @salkar.favorite @salkar_post
    @morozovm.favorite @salkar_post
    ::Inkwell::FavoriteItem.all.size.should == 2
    @salkar_post.reload
    @salkar.unfavorite @salkar_post
    @salkar_post.reload
    ::Inkwell::FavoriteItem.all.size.should == 1
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_post.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == [@morozovm.id]
  end

  it "User should unfavorite comment" do
    @salkar.favorite @salkar_comment
    @salkar_comment.reload
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar.unfavorite @salkar_comment
    @salkar_comment.reload
    ::Inkwell::FavoriteItem.all.size.should == 0
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_comment.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == []

    @salkar.favorite @salkar_comment
    @morozovm.favorite @salkar_comment
    ::Inkwell::FavoriteItem.all.size.should == 2
    @salkar_comment.reload
    @morozovm.unfavorite @salkar_comment
    @salkar_comment.reload
    ::Inkwell::FavoriteItem.all.size.should == 1
    users_ids_who_favorite_it = ActiveSupport::JSON.decode(@salkar_comment.users_ids_who_favorite_it)
    users_ids_who_favorite_it.should == [@salkar.id]
  end

  it "Unfavorite not favorited obj should not return error" do
    @salkar.favorite?(@salkar_comment).should == false
    @salkar.favorite?(@salkar_post).should == false
    @salkar.unfavorite @salkar_comment
    @salkar.unfavorite @salkar_post
  end

  it "Favoriteline should been return" do
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.comments.create :post_id => @salkar_post.id, :body => "salkar_comment_body"
    @morozovm_post = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_comment = @morozovm.comments.create :post_id => @morozovm_post.id, :body => "salkar_comment_body"
    @salkar_comment1 = @salkar.comments.create :post_id => @morozovm_post.id, :body => "salkar_comment_body"
    @morozovm_post1 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post2 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post3 = @morozovm.posts.create :body => "salkar_post_test_body"
    @salkar_comment2 = @salkar.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @salkar_comment3 = @salkar.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @salkar_comment4 = @salkar.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @morozovm_comment2 = @morozovm.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body"

    @salkar.favorite @salkar_post
    @salkar.favorite @salkar_comment
    @salkar.favorite @morozovm_post
    @salkar.favorite @morozovm_comment
    @salkar.favorite @salkar_comment1
    @salkar.favorite @morozovm_post1
    @salkar.favorite @morozovm_post2
    @salkar.favorite @morozovm_post3
    @salkar.favorite @salkar_comment2
    @salkar.favorite @salkar_comment3
    @salkar.favorite @salkar_comment4
    @salkar.favorite @morozovm_comment2
    @salkar.favorite @salkar_post1

    fline = @salkar.favoriteline
    fline.size.should == 10
    fline[0].id.should == @salkar_post1.id
    fline[0].class.to_s.should == 'Post'
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@salkar_post1.id, false).id
    fline[9].id.should == @morozovm_comment.id
    fline[9].class.to_s.should == 'Inkwell::Comment'
    fline[9].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@morozovm_comment.id, true).id

    from_favorite_item_id = ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@morozovm_comment2.id, true).id
    fline = @salkar.favoriteline(from_favorite_item_id)
    fline.size.should == 10
    fline[0].id.should == @salkar_comment4.id
    fline[0].class.to_s.should == 'Inkwell::Comment'
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@salkar_comment4.id, true).id
    fline[9].id.should == @salkar_comment.id
    fline[9].class.to_s.should == 'Inkwell::Comment'
    fline[9].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@salkar_comment.id, true).id

    from_favorite_item_id = ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@morozovm_comment2.id, true).id
    fline = @salkar.favoriteline(from_favorite_item_id, 5)
    fline.size.should == 5
    fline[0].id.should == @salkar_comment4.id
    fline[0].class.to_s.should == 'Inkwell::Comment'
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@salkar_comment4.id, true).id
    fline[4].id.should == @morozovm_post2.id
    fline[4].class.to_s.should == 'Post'
    fline[4].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@morozovm_post2.id, false).id
  end

  it "Favoriteline should been return for for_user" do
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.comments.create :post_id => @salkar_post.id, :body => "salkar_comment_body"
    @morozovm_post = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_comment = @morozovm.comments.create :post_id => @morozovm_post.id, :body => "salkar_comment_body"
    @salkar_comment1 = @salkar.comments.create :post_id => @morozovm_post.id, :body => "salkar_comment_body"
    @morozovm_post1 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post2 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post3 = @morozovm.posts.create :body => "salkar_post_test_body"
    @salkar_comment2 = @salkar.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @salkar_comment3 = @salkar.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @salkar_comment4 = @salkar.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @morozovm_comment2 = @morozovm.comments.create :post_id => @morozovm_post3.id, :body => "salkar_comment_body"
    @salkar_post1 = @salkar.posts.create :body => "salkar_post_test_body"

    @salkar.favorite @salkar_post
    @salkar.favorite @salkar_comment
    @salkar.favorite @morozovm_post
    @salkar.favorite @morozovm_comment
    @salkar.favorite @salkar_comment1
    @salkar.favorite @morozovm_post1
    @salkar.favorite @morozovm_post2
    @salkar.favorite @morozovm_post3
    @salkar.favorite @salkar_comment2
    @salkar.favorite @salkar_comment3
    @salkar.favorite @salkar_comment4
    @salkar.favorite @morozovm_comment2
    @salkar.favorite @salkar_post1
    @morozovm.favorite @salkar_post1
    @morozovm.favorite @morozovm_comment
    @morozovm.reblog @salkar_comment4
    @morozovm.reblog @salkar_post1


    fline = @salkar.favoriteline(nil,10,@morozovm)
    fline.size.should == 10
    fline[0].id.should == @salkar_post1.id
    fline[0].class.to_s.should == 'Post'
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@salkar_post1.id, false).id
    fline[0].is_favorited.should == true
    fline[0].is_reblogged.should == true
    fline[2].id.should == @salkar_comment4.id
    fline[2].class.to_s.should == 'Inkwell::Comment'
    fline[2].is_reblogged.should == true
    fline[9].id.should == @morozovm_comment.id
    fline[9].class.to_s.should == 'Inkwell::Comment'
    fline[9].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_is_comment(@morozovm_comment.id, true).id
    fline[9].is_favorited.should == true
    for i in 1..8
      fline[i].is_favorited.should == false
    end
  end

end