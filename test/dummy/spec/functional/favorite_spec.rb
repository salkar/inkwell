require "spec_helper"

describe "Favorites" do

  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.create_comment :for_object => @salkar_post, :body => "salkar_comment_body"
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
    ::Inkwell::FavoriteItem.create :item_id => @salkar_post.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::POST, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar.favorite?(@salkar_post).should == true
  end

  it "Post should not been favorited" do
    ::Inkwell::FavoriteItem.all.size.should == 0
    @salkar.favorite?(@salkar_post).should == false
  end

  it "Comment should been favorited" do
    ::Inkwell::FavoriteItem.create :item_id => @salkar_comment.id, :owner_id => @salkar.id, :item_type => ::Inkwell::Constants::ItemTypes::COMMENT, :owner_type => ::Inkwell::Constants::OwnerTypes::USER
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar.favorite?(@salkar_comment).should == true
    @salkar_comment.reload
    @salkar_comment.favorite_count.should == 1
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
    @salkar_post.favorite_count.should == 1
    @morozovm.favorite @salkar_post
    @morozovm.favorite?(@salkar_post).should == true
    ::Inkwell::FavoriteItem.all.size.should == 2
    @salkar_post.reload
    @salkar_post.favorite_count.should == 2
  end

  it "User should favorite comment" do
    @salkar.favorite @salkar_comment
    @salkar.favorite?(@salkar_comment).should == true
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar_comment.reload
    @salkar_comment.favorite_count.should == 1
    @morozovm.favorite @salkar_comment
    @morozovm.favorite?(@salkar_comment).should == true
    ::Inkwell::FavoriteItem.all.size.should == 2
    @salkar_comment.reload
    @salkar_comment.favorite_count.should == 2
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
    @salkar_post.favorite_count.should == 1
  end

  it "User should unfavorite comment" do
    @salkar.favorite @salkar_comment
    @salkar_comment.reload
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar.unfavorite @salkar_comment
    @salkar_comment.reload
    ::Inkwell::FavoriteItem.all.size.should == 0
    @salkar_comment.favorite_count.should == 0

    @salkar.favorite @salkar_comment
    @morozovm.favorite @salkar_comment
    ::Inkwell::FavoriteItem.all.size.should == 2
    @salkar_comment.reload
    @morozovm.unfavorite @salkar_comment
    @salkar_comment.reload
    ::Inkwell::FavoriteItem.all.size.should == 1
    @salkar_comment.favorite_count.should == 1
  end

  it "Unfavorite not favorited obj should not return error" do
    @salkar.favorite?(@salkar_comment).should == false
    @salkar.favorite?(@salkar_post).should == false
    @salkar.unfavorite @salkar_comment
    @salkar.unfavorite @salkar_post
  end

  it "Favoriteline should been return" do
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.create_comment :for_object => @salkar_post, :body => "salkar_comment_body"
    @morozovm_post = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_comment = @morozovm.create_comment :for_object => @morozovm_post, :body => "salkar_comment_body"
    @salkar_comment1 = @salkar.create_comment :for_object => @morozovm_post, :body => "salkar_comment_body"
    @morozovm_post1 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post2 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post3 = @morozovm.posts.create :body => "salkar_post_test_body"
    @salkar_comment2 = @salkar.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
    @salkar_comment3 = @salkar.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
    @salkar_comment4 = @salkar.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
    @morozovm_comment2 = @morozovm.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
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
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@salkar_post1.id, ::Inkwell::Constants::ItemTypes::POST).id
    fline[9].id.should == @morozovm_comment.id
    fline[9].class.to_s.should == 'Inkwell::Comment'
    fline[9].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@morozovm_comment.id, ::Inkwell::Constants::ItemTypes::COMMENT).id

    fline_same = @salkar.favoriteline :last_shown_obj_id => nil, :limit => 10, :for_user => nil
    fline_same.should == fline

    from_favorite_item_id = ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@morozovm_comment2.id, ::Inkwell::Constants::ItemTypes::COMMENT).id
    fline = @salkar.favoriteline(:last_shown_obj_id => from_favorite_item_id)
    fline.size.should == 10
    fline[0].id.should == @salkar_comment4.id
    fline[0].class.to_s.should == 'Inkwell::Comment'
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@salkar_comment4.id, ::Inkwell::Constants::ItemTypes::COMMENT).id
    fline[9].id.should == @salkar_comment.id
    fline[9].class.to_s.should == 'Inkwell::Comment'
    fline[9].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@salkar_comment.id, ::Inkwell::Constants::ItemTypes::COMMENT).id

    from_favorite_item_id = ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@morozovm_comment2.id, ::Inkwell::Constants::ItemTypes::COMMENT).id
    fline = @salkar.favoriteline(:last_shown_obj_id => from_favorite_item_id, :limit => 5)
    fline.size.should == 5
    fline[0].id.should == @salkar_comment4.id
    fline[0].class.to_s.should == 'Inkwell::Comment'
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@salkar_comment4.id, ::Inkwell::Constants::ItemTypes::COMMENT).id
    fline[4].id.should == @morozovm_post2.id
    fline[4].class.to_s.should == 'Post'
    fline[4].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@morozovm_post2.id, ::Inkwell::Constants::ItemTypes::POST).id
  end

  it "Favoriteline should been return for for_user" do
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
    @salkar_comment = @salkar.create_comment :for_object => @salkar_post, :body => "salkar_comment_body"
    @morozovm_post = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_comment = @morozovm.create_comment :for_object => @morozovm_post, :body => "salkar_comment_body"
    @salkar_comment1 = @salkar.create_comment :for_object => @morozovm_post, :body => "salkar_comment_body"
    @morozovm_post1 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post2 = @morozovm.posts.create :body => "salkar_post_test_body"
    @morozovm_post3 = @morozovm.posts.create :body => "salkar_post_test_body"
    @salkar_comment2 = @salkar.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
    @salkar_comment3 = @salkar.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
    @salkar_comment4 = @salkar.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
    @morozovm_comment2 = @morozovm.create_comment :for_object => @morozovm_post3, :body => "salkar_comment_body"
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


    fline = @salkar.favoriteline(:for_user => @morozovm)
    fline.size.should == 10
    fline[0].id.should == @salkar_post1.id
    fline[0].class.to_s.should == 'Post'
    fline[0].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@salkar_post1.id, ::Inkwell::Constants::ItemTypes::POST).id
    fline[0].is_favorited.should == true
    fline[0].is_reblogged.should == true
    fline[2].id.should == @salkar_comment4.id
    fline[2].class.to_s.should == 'Inkwell::Comment'
    fline[2].is_reblogged.should == true
    fline[9].id.should == @morozovm_comment.id
    fline[9].class.to_s.should == 'Inkwell::Comment'
    fline[9].item_id_in_line.should == ::Inkwell::FavoriteItem.find_by_item_id_and_item_type(@morozovm_comment.id, ::Inkwell::Constants::ItemTypes::COMMENT).id
    fline[9].is_favorited.should == true
    for i in 1..8
      fline[i].is_favorited.should == false
    end
  end

  it "favorite count should been received for post" do
    @talisman = User.create :nick => "Talisman"
    @salkar_post.reload
    @salkar_post.favorite_count.should == 0
    @morozovm.favorite @salkar_post
    @talisman.favorite @salkar_post
    @salkar_post.reload
    @salkar_post.favorite_count.should == 2
  end

  it "favorite count should been received for post" do
    @talisman = User.create :nick => "Talisman"
    @salkar_comment.reload
    @salkar_comment.favorite_count.should == 0
    @morozovm.favorite @salkar_comment
    @talisman.favorite @salkar_comment
    @salkar_comment.reload
    @salkar_comment.favorite_count.should == 2
  end

end