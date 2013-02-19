# Inkwell

Inkwell provides simple way to add social networking features like comments,
reblogs, favorites, following/followers, communities and timelines to your
Ruby on Rails application.

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NYTZGSJD3H3BC)

Russian translation of README file available
[here](https://github.com/salkar/inkwell/blob/master/README_RU.rdoc).

## Requirements
You should have two classes: User and Post or other identical. Between them
should be a one-to-many relationship. For example:

    class User < ActiveRecord::Base
      has_many :posts
    end

    class Post < ActiveRecord::Base
      belongs_to :user
    end

If you want to use
[communities](https://github.com/salkar/inkwell#community-feature), then you
need to have `Community` class, too:

    class Community < ActiveRecord::Base
    end

## Installation

Put in `Gemfile`:

    gem 'inkwell', :git => 'git://github.com/salkar/inkwell.git'

After it do `bundle install`

Add to your `User` model `acts_as_inkwell_user` and to your `Post` model
`acts_as_inkwell_post`

    class User < ActiveRecord::Base
      has_many :posts
      acts_as_inkwell_user
    end

    class Post < ActiveRecord::Base
      belongs_to :user
      acts_as_inkwell_post
    end

If you want to use communities, then add to your `Community` model
`acts_as_inkwell_community`:

    class Community < ActiveRecord::Base
      acts_as_inkwell_community
    end

Create `inkwell.rb` file in `config/initializers` and put in it your names of
`User` and `Post` tables (or other identical).  Put in it name of `Community`
table if you want to use it:

    module Inkwell
      class Engine < Rails::Engine
        config.post_table = :posts
        config.user_table = :users
        config.community_table = :communities #if you want to use communities
      end
    end

Next, get gem migrations:

    rake inkwell:install:migrations

and `db:migrate` it.

## Usage

### Favorite features

User is able to favorite posts/comments:

    @user.favorite @post
    @user.favorite @comment

To delete post/comment from favorites:

    @user.unfavorite @post

To check that post/comment enters in favorites:

    @user.favorite? @post

To return favorite line, consisting of favorited posts and comments:

    @user.favoriteline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)

where 
*   `last_shown_obj_id` - id of the last item in favorite line shown to the
    user. Get it from the `item_id_in_line` property of last item from
    previous `favoriteline` calls. This parameter is used for pagination and
    separation of the timeline.

        fline = @user.favoriteline    #get first 10 items from @user favorite line
        last_shown_obj_id = fline.last.item_id_in_line
        fline_next_page = @user.favoriteline :last_shown_obj_id => last_shown_obj_id    #get next 10 items from @user favorite line

*   `limit` - defines the count of favorited items to return.

        fline = @user.favoriteline :limit => 20    #return first 20 items from @user favorite line

*   `for_user` - `User`, who looks this favorite line. For him `is_reblogged`
    and `is_favorited` properties will been formed. 

        @user.favorite @another_user_post
        @user.reblog @another_user_post

        fline_for_unknown_user = @another_user.favoriteline
        # For example, fline_for_unknown_user.first == @another_user_post
        fline_for_unknown_user.first.is_reblogged    # => false
        fline_for_unknown_user.first.is_favorited    # => false

        fline_for_user_who_reblog_and_favorite_another_user_post = @another_user.favoriteline :for_user => @user
        # For example, fline_for_user_who_reblog_and_favorite_another_user_post.first == @another_user_post
        fline_for_user_who_reblog_and_favorite_another_user_post.first.is_reblogged    # => true
        fline_for_user_who_reblog_and_favorite_another_user_post.first.is_favorited    # => true


More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functiona
l/favorite_spec.rb).

### Reblog features

Reblog means that reblogged post will be added to user's blogline and to
timelines of his followers. Thus, the behavior of reblogged object is similar
to the post of the user who made this reblog. User is able to reblog
posts/comments:

    @user.reblog @post
    @user.reblog @comment

To delete post/comment from reblogs:

    @user.unreblog @post

To check that post/comment enters in reblogs:

    @user.reblog? @post

Reblogs don't have their own line and are contained in user's blogline.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functiona
l/reblog_spec.rb).

### Comment features

User is able to create comments for post or other comment. If you want to
comment the post:

    @user.create_comment :for_object => @post, :body => "comment_body"

If you want to comment other comment you should add `parent_comment_id` of parent
comment:

    @user.create_comment :for_object => @parent_post, :body => "comment_body", :parent_comment_id => @parent_comment.id

To delete comment you should use `destroy` method:

    @comment.destroy

You are able to get comment line for post or comment. It consists of comments
for this object in reverse chronological order.

*Notice: returned array will have back order to simplify the use. Last comment
is at the bottom usually.*

To get comment line:

    commentline(:last_shown_comment_id => nil, :limit => 10, :for_user => nil)

where `last_shown_comment_id` is id of last shown comment from previous
commentline results. For example:

    cline = @post.commentline    #get last 10 comments for @post
    last_shown_comment_id = cline.first.id    # First element is taken due to reverse order. In fact, it is the oldest of these comments.
    cline_next_page = @post.commentline :last_shown_comment_id => last_shown_comment_id

`Limit` and `for_user` mean the same thing as in the
[favoriteline](https://github.com/salkar/inkwell#favorite-features).

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functiona
l/comments_spec.rb).

### Follow features

User is able to follow another users. It allows him to get followed user's
blogline in his timeline.

To follow user:

    @user.follow @another_user

After it last 10 `@another_user` blogline's items will be transferred to
`@user` timeline. And each new `@another_user` blogline item will be added to
`@user` timeline.

To unfollow user:

    @user.unfollow @another_user

To check that user is follower of another user:

    @user.follow? @another_user

To get followers ids for user and ids of users, which he follow:

    @user.followers_row
    @user.followings_row

Both methods return arrays of ids.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functiona
l/following_spec.rb).

### Blogline feature

User blogline is consists of his posts and his reblogs. To get it:

    @user.blogline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)

where parameters are similar with described
[above](https://github.com/salkar/inkwell#favorite-features) favoriteline
parameters.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functiona
l/blogline_spec.rb).

### Timeline feature

User timeline is consists of items from bloglines of users he follows. To get
it:

    @user.timeline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)

where parameters are similar with described
[above](https://github.com/salkar/inkwell#favorite-features) favoriteline
parameters.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functiona
l/timeline_spec.rb).

### Community feature

Community is association of users. It has own blogline, consisting of posts of
its members. Community member can send his post to the community blogline.
Then this post is added to the timelines of other community users.

There are two types of community: private and public. Users can join public community when they want - no one controls this process (They should not be banned in it).
The user should leave the invitation request to join the private community. Then the admin will review it and add the user to the community or reject the request.

When you create community you need to pass `owner_id`. To create public community:

    @community = Community.create :name => "Community", :owner_id => @user.id 
    
To create private community you need to pass `:public => false` in addition to the rest: 

    @private_community = Community.create :name => "Private Community", :owner_id => @user.id, :public => false

User with the passed id (`owner_id`) will be the first administrator of created community
and will be added to it.

To add a user to the public community:

    @user.join @community

After it last 10 `@community` blogline's items will be transferred to `@user`
timeline. And each new `@community` blogline item will be added to `@user`
timeline. Moreover `@user` will be able to add their posts in community
blogline.

To send invitation request to the private community:

    @private_community.create_invitation_request @user
    
To accept invitation request: 

    @private_community.accept_invitation_request :user => @user, :admin => @admin
    
To reject invitation request:

    @private_community.reject_invitation_request :user => @user, :admin => @admin
    
To prevent invitation requests spam you are able to ban spamming users.

To remove a user from community:

    @admin.kick :user => @user, :from_community => @community

where `admin` is community administrator and `@user` is deleted user.

If user leave community:

    @user.leave @community

After leaving the community (both methods) its blogline items will be removed
from the user timeline.

To send post to the community blogline:

    @user.send_post_to_community :post => @user_post, :to_community => @community
    
Preferably check the possibility of sending a post by `@user` before using `send_post_to_community`. To check user permissions for post sending:

    @user.send_post_to_community :post => @user_post, :to_community => @community
        if @user.can_send_post_to_community? @community

Sent post will be added to timelines of community members. A post can be sent
to the community only by its owner.

To remove post from community blogline:

    @user.remove_post_from_community :post => @user_post, :from_community => @community

or 

    @admin.remove_post_from_community :post => @user_post, :from_community => @community

Only post owner or administrator of community can remove the post from the
community blogline.

To check that the user is a member of the community:

    @community.include_user? @user

To check that the user is an admin of the community:

    @community.include_admin? @user

Each administrator has the access level. Community owner has access level 0.
Administrators, to whom he granted admin permissions, have access level 1 and
so on. Thus the lower the access level, the more permissions. For example,
admin with access level 0 can delete admin with access level 1 but not vice
versa.

To grant admin permissions:

    @admin.grant_admin_permissions :to_user => @new_admin, :in_community => @community

To revoke admin permissions:

    @admin.revoke_admin_permissions :user => @admin_who_is_removed, :in_community => @community

To get admin's access level:

    @community.admin_level_of @admin 

To get communities ids in which there is this post:

    @post.communities_row

To get ids of community members:

    @community.users_row

To get ids of communities to which the user has joined:

    @user.communities_row
    
Admin of community is able to mute or ban user. Muted users is not able to send posts to community, but they are still in it.
Banned users are not in community and are not able to join it or send invite in it.

To mute user:

    @admin.mute :user => @user, :in_community => @community
    
To unmute user:

    @admin.unmute :user => @user, :in_community => @community
    
To check that user is muted:

    @community.include_muted_user? @user
    
To ban user:

    @admin.ban :user => @user, :in_community => @community
    
To unban user:
    
    @admin.unban :user => @user, :in_community => @community
    
To check that user is banned:

    @community.include_banned_user? @user

Community blogline is consists of the posts of members that have added to it.
To get it:

    @community.blogline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)

where parameters are similar with described
[above](https://github.com/salkar/inkwell#favorite-features) favoriteline
parameters.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/lib/acts_as_inkwell_commu
nity/base.rb)

## License
Inkwell is Copyright © 2013 Sergey Sokolov. It is free software, and may be
redistributed under the terms specified in the MIT-LICENSE file.

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/ca9e83bea0d6c79d5909780eb805e944 "githalytics.com")](http://githalytics.com/salkar/inkwell)
