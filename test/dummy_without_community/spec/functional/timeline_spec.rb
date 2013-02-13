require "spec_helper"

describe "Timeline" do
  before(:each) do
    @salkar = User.create :nick => "Salkar"
    @morozovm = User.create :nick => "Morozovm"
    @talisman = User.create :nick => "Talisman"
    @salkar_post = @salkar.posts.create :body => "salkar_post_test_body"
  end

  it "user should has timeline" do
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
    @salkar.favorite @morozovm_post1

    @talisman.follow @salkar
    @talisman.reload
    @talisman.follow @morozovm
    @talisman.reload

    tline = @talisman.timeline(:for_user => @salkar)
    tline.size.should == 10
    tline[0].should == @morozovm_post2
    tline[1].should == @morozovm_post1
    tline[1].from_sources_in_timeline.should == ActiveSupport::JSON.encode([{'user_id' => @salkar.id, 'type' => 'reblog'}, {'user_id' => @morozovm.id, 'type' => 'following'}])
    tline[1].is_reblogged.should == true
    tline[1].is_favorited.should == true
    tline[2].should == @morozovm_post3
    tline[3].should == @salkar_post9
    tline[3].from_sources_in_timeline.should == ActiveSupport::JSON.encode([{'user_id' => @salkar.id, 'type' => 'following'}])
    tline[3].is_reblogged.should == false
    tline[3].is_favorited.should == false
    tline[4].should == @salkar_post8
    tline[5].should == @salkar_post7
    tline[6].should == @salkar_post6
    tline[7].should == @morozovm_post
    tline[8].should == @salkar_post5
    tline[9].should == @salkar_post4
  end

  it "comment should been in timeline" do
    @salkar_comment = @salkar.create_comment :for_object => @salkar_post, :body => "salkar_comment_body"
    @talisman.follow @morozovm
    @morozovm.reblog @salkar_comment
    @morozovm.favorite @salkar_comment
    @talisman.reload
    tline = @talisman.timeline(:last_shown_obj_id => nil, :limit => 10,:for_user => @morozovm)
    tline.size.should == 1
    tline[0].should == @salkar_comment
    tline[0].is_reblogged.should == true
    tline[0].is_favorited.should == true
    tline[0].from_sources_in_timeline.should == ActiveSupport::JSON.encode([{'user_id' => @morozovm.id, 'type' => 'reblog'}])
  end
end