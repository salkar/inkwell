# Inkwell

Inkwell provides a simple way to add social networking features 
(e.g., comments, reblogs, favorites, following/followers, communities and timelines) to your
Ruby on Rails application.

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NYTZGSJD3H3BC)

References that may be useful:

[Building Social Apps with Rails: inkwell](http://www.matthewpbyrne.com/blog/2014/01/09/building-social-apps-with-rails-inkwell/)

Russian translation of README file available
[here](https://github.com/salkar/inkwell/blob/master/README_RU.rdoc).

- - -
You can extend the functionality of Inkwell by using [inkwell_timelines](https://github.com/salkar/inkwell_timelines). 
Inkwell_timelines gem contains helpers which provide a way to create timelines with content autoload on scrolling.
Additionally it allows you to group timelines in timeline blocks.
![Inkwell Timelines](https://github.com/salkar/inkwell_timelines/blob/master/test/screen/main-mini.png?raw=true)

- - -

## Requirements
You should have User and Post (or other identical) classes declared in your application. They
should have a one-to-many relationship. For example:

```ruby
class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end
```

If you want to use
[communities](https://github.com/salkar/inkwell#community-feature), you
need to have `Community` class:

```ruby
class Community < ActiveRecord::Base
end
```

If you want to use
[categories](https://github.com/salkar/inkwell#category-feature), you
need to have `Category` class too:

```ruby
class Category < ActiveRecord::Base
end
```

*MySQL* can't set default value for BLOB/TEXT fields so currently only *sqlite3* and *PostgreSQL* are supported.


## Installation

To get Inkwell from RubyGems, put the following line in the `Gemfile`.

```ruby
gem 'inkwell'
```

Alternatively, you can get it from Github (This version may contain unfinished features).

```ruby
gem 'inkwell', :git => 'git://github.com/salkar/inkwell.git'
```

After that, run `bundle install`

Add the line `acts_as_inkwell_user` to your `User` model and the line `acts_as_inkwell_post` to your `Post` model.

```ruby
class User < ActiveRecord::Base
  has_many :posts
  acts_as_inkwell_user
end

class Post < ActiveRecord::Base
  belongs_to :user
  acts_as_inkwell_post
end
```

If you want to use communities, add the line `acts_as_inkwell_community` to your `Community` model.

```ruby
class Community < ActiveRecord::Base
  acts_as_inkwell_community
end
```

If you want to use categories, add the line `acts_as_inkwell_category` to your `Category` model.

```ruby
class Category < ActiveRecord::Base
  acts_as_inkwell_category
end
```

Create a file (named `inkwell.rb`) in `config/initializers` and add names of
`User` and `Post` tables (or other identical) in this file.  If you want to use `Community`/`Category`, add names of 
their table to `inkwell.rb`.

```ruby
module Inkwell
  class Engine < Rails::Engine
    config.post_table = :posts
    config.user_table = :users
    config.community_table = :communities #if you want to use communities
    config.category_table = :categories #if you want to use categories
  end
end
```

Next, get gem migrations:

```bash
$ rake inkwell:install:migrations
```

and `rake db:migrate` them.

## Upgrading

After upgrading Inkwell remember to get new migrations and migrate them.

```bash
$ rake inkwell:install:migrations
$ rake db:migrate
```

## Usage

### Favoriting features

User is able to favorite posts/comments:

```ruby
@user.favorite @post
@user.favorite @comment
```

To delete post/comment from favorites:

```ruby
@user.unfavorite @post
```

To check if post/comment is in favorites:

```ruby
@user.favorite? @post
```

To get favorite line, consisting of favorited posts and comments:

```ruby
@user.favoriteline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)
```

where
*   `last_shown_obj_id` - id of the last item in favorite line shown to the
    user. Get the id from the `item_id_in_line` property of the last item from
    previous `favoriteline` call. This parameter is used for pagination and
    separation of the timeline.

    ```ruby
    fline = @user.favoriteline    #get first 10 items from @user favorite line
    last_shown_obj_id = fline.last.item_id_in_line
    fline_next_page = @user.favoriteline :last_shown_obj_id => last_shown_obj_id    #get next 10 items from @user favorite line
    ```

*   `limit` - the count of favorited items to return.

    ```ruby
    fline = @user.favoriteline :limit => 20    #return first 20 items from @user favorite line
    ```

*   `for_user` - `User`, who gets this favorite line. For him `is_reblogged`
    and `is_favorited` properties will been formed.

    ```ruby
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
    ```

For more examples refer to
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functional/favorite_spec.rb).

### Reblogging features

If the post is reblogged, it will be added to user's blogline and to
timelines of his followers. Thus, the behavior of reblogged object is similar
to the post of the user who made this reblog. User is able to reblog
posts/comments:

```ruby
@user.reblog @post
@user.reblog @comment
```

To delete post/comment from reblogs:

```ruby
@user.unreblog @post
```

To check if post/comment is in reblogs:

```ruby
@user.reblog? @post
```

Reblogs don't have their own line and reside in user's blogline.

For more examples refer to
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functional/reblog_spec.rb).

### Commenting features

User is able to create comments for post or other comment. If you want to
comment the post:

```ruby
@user.create_comment :for_object => @post, :body => "comment_body"
```

If you want to comment other comment you should add `parent_comment_id` of parent
comment:

```ruby
@user.create_comment :for_object => @parent_post, :body => "comment_body", :parent_comment_id => @parent_comment.id
```

To delete comment you should use `destroy` method:

```ruby
@comment.destroy
```

You are able to get comment line for post or comment. It consists of comments
for this object in reverse chronological order.

*Notice: returned array will have back order to simplify the use. Last comment
is at the bottom usually.*

To get comment line:

```ruby
commentline(:last_shown_comment_id => nil, :limit => 10, :for_user => nil)
```

where `last_shown_comment_id` is id of last shown comment from previous
commentline results. For example:

```ruby
cline = @post.commentline    #get last 10 comments for @post
last_shown_comment_id = cline.first.id    # First element is taken due to reverse order. In fact, it is the oldest of these comments.
cline_next_page = @post.commentline :last_shown_comment_id => last_shown_comment_id
```

`Limit` and `for_user` mean the same thing as in the
[favoriteline](https://github.com/salkar/inkwell#favorite-features).

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functional/comments_spec.rb).

### Following features

User is able to follow another users. It allows him to get followed user's
blogline in his timeline.

To follow user:

```ruby
@user.follow @another_user
```

After it last 10 `@another_user` blogline's items will be transferred to
`@user` timeline. And each new `@another_user` blogline item will be added to
`@user` timeline.

To unfollow user:

```ruby
@user.unfollow @another_user
```

To check that user is follower of another user:

```ruby
@user.follow? @another_user
```

To get followers ids for user and ids of users, which he follow:

```ruby
@user.followers_row
@user.followings_row
```

Or if you need User objects:

```ruby
@user.followers
@user.followings
```

Both methods return arrays of ids.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functional/following_spec.rb).

### Blogline feature

User blogline is consists of his posts and his reblogs. To get it:

```ruby
@user.blogline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)
```

where parameters are similar with described
[above](https://github.com/salkar/inkwell#favorite-features) favoriteline
parameters.

If you want to get `blogline` items located in the category, pass `category` param:

```ruby
@user.blogline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil, :category => category) 
```

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functional/blogline_spec.rb).

### Timeline feature

User timeline is consists of items from bloglines of users he follows. To get
it:

```ruby
@user.timeline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)
```

where parameters are similar with described
[above](https://github.com/salkar/inkwell#favorite-features) favoriteline
parameters.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functional/timeline_spec.rb).

### Community feature

Community is association of users. It has own blogline, consisting of posts of
its members. Community member can send his post to the community blogline.
Then this post is added to the timelines of other community users.

There are two types of community: private and public. Users can join public community when they want - no one controls this process (They should not be banned in it).
The user should leave the invitation request to join the private community. Then the admin will review it and add the user to the community or reject the request.

When you create community you need to pass `owner_id`. To create public community:

```ruby
@community = Community.create :name => "Community", :owner_id => @user.id
```

To create private community you need to pass `:public => false` in addition to the rest:

```ruby
@private_community = Community.create :name => "Private Community", :owner_id => @user.id, :public => false
```

User with the passed id (`owner_id`) will be the first administrator of created community
and will be added to it.

To add a user to the public community:

```ruby
@user.join @community
```

After it last 10 `@community` blogline's items will be transferred to `@user`
timeline. And each new `@community` blogline item will be added to `@user`
timeline. Moreover `@user` will be able to add their posts in community
blogline.

To send invitation request to the private community:

```ruby
@user.request_invitation @private_community
```

To accept invitation request:

```ruby
@admin.approve_invitation_request :user => @user, :community => @private_community
```

To reject invitation request:

```ruby
@admin.reject_invitation_request :user => @user, :community => @private_community
```

To prevent invitation requests spam you are able to ban spamming users.

To get asked invitation users:

```ruby
@community.asked_invitation_users
```

To get ids of asked invitation users:

```ruby
@community.invitations_row
```

To remove a user from community:

```ruby
@admin.kick :user => @user, :from_community => @community
```

where `admin` is community administrator and `@user` is deleted user.

If user leave community:

```ruby
@user.leave @community
```

After leaving the community (both methods) its blogline items will be removed
from the user timeline.

To send post to the community blogline:

```ruby
@user.send_post_to_community :post => @user_post, :to_community => @community
```

Preferably check the possibility of sending a post by `@user` before using `send_post_to_community`. To check user permissions for post sending:

```ruby
@user.send_post_to_community :post => @user_post, :to_community => @community
    if @user.can_send_post_to_community? @community
```

Sent post will be added to timelines of community members. A post can be sent
to the community only by its owner.

To remove post from community blogline:

```ruby
@user.remove_post_from_community :post => @user_post, :from_community => @community
```

or

```ruby
@admin.remove_post_from_community :post => @user_post, :from_community => @community
```

Only post owner or administrator of community can remove the post from the
community blogline.

To check that the user is a member of the community:

```ruby
@community.include_user? @user
```

To check that the user is an admin of the community:

```ruby
@community.include_admin? @user
```

Each administrator has the access level. Community owner has access level 0.
Administrators, to whom he granted admin permissions, have access level 1 and
so on. Thus the lower the access level, the more permissions. For example,
admin with access level 0 can delete admin with access level 1 but not vice
versa.

To grant admin permissions:

```ruby
@admin.grant_admin_permissions :to_user => @new_admin, :in_community => @community
```

To revoke admin permissions:

```ruby
@admin.revoke_admin_permissions :user => @admin_who_is_removed, :in_community => @community
```

To get admin's access level:

```ruby
@community.admin_level_of @admin
```

To get communities ids in which there is this post:

```ruby
@post.communities_row
```

To get ids of community members:

```ruby
@community.users_row
```

To get community members:

```ruby
@community.users
```

To get ids of community administrators:

```ruby
@community.admins_row
```

To get community administrators:

```ruby
@community.admins
```

To get ids of communities to which the user has joined:

```ruby
@user.communities_row
```

To get communities to which the user has joined:

```ruby
@user.communities
```

Admin of community is able to mute or ban user. Muted users is not able to send posts to community, but they are still in it.
Banned users are not in community and are not able to join it or send invite in it.

To mute user:

```ruby
@admin.mute :user => @user, :in_community => @community
```

To unmute user:

```ruby
@admin.unmute :user => @user, :in_community => @community
```

To check that user is muted:

```ruby
@community.include_muted_user? @user
```

To get muted users:

```ruby
@community.muted_users
```

To ban user:

```ruby
@admin.ban :user => @user, :in_community => @community
```

To unban user:

```ruby
@admin.unban :user => @user, :in_community => @community
```

To check that user is banned:

```ruby
@community.include_banned_user? @user
```

To get banned users:

```ruby
@community.banned_users
```

Community's users can have different types of access to community - some of them can send post to it, other can not.
This applies to both types of community - private and public. By default all new users can send posts to the community (except for the muted users).
*Notice: do not forget to check the admin rights for operations with Read/Write community access*

To set default access for new users to read (does not affect users who are already in the community):

```ruby
@community.change_default_access_to_read
```

To set default access for new users to write (does not affect users who are already in the community):

```ruby
@community.change_default_access_to_write
```

To set write access for users who are already in the community:

```ruby
@community.set_write_access [@user.id, @another_user.id]
```

To set read access for users who are already in the community:

```ruby
@community.set_read_access [@user.id, @another_user.id]
```

To get ids of users with write access (result could include muted users ids):

```ruby
@community.writers_row
```

To get users with write access (result could include muted users ids):

```ruby
@community.writers
```

Community blogline is consists of the posts of members that have added to it.

To get it:

```ruby
@community.blogline(:last_shown_obj_id => nil, :limit => 10, :for_user => nil)
```

where parameters are similar with described
[above](https://github.com/salkar/inkwell#favorite-features) favoriteline
parameters.

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/lib/acts_as_inkwell_community/base.rb)

### Category feature
Blog items (posts, reblogged comments, etc) can be combined in the category (for example - coding, travel, games).
Each blog item may be contained in several categories, and category can have many items.
Category should be used when the user writes on different themes, and need to add sort in his blog.
Categories can also be used in the community blog.
Category can contain subcategories.

To create category:

```ruby
user.create_category :name => "test category" #     name - test params, insert your parameters instead of it
community.create_category :name => "test category" #     name - test params, insert your parameters instead of it
```

To create subcategory:

```ruby
category = @user.create_category :name => "test category"
user.create_category :name => "test subcategory", :parent_category_id => category.id
```

To destroy category:

```ruby
category.destroy
```

To get the list of categories:

```ruby
list = user.get_categories
list = community.get_categories
```

`list` will contain all categories of user / community.
All items in it will contain a parameter `parent_category_id`. Using it you can restore category tree.

To add blog item to the category:

```ruby
category.add_item :item => post, :owner => category_owner
```

To remove blog item from the category:

```ruby
category.remove_item :item => post, :owner => category_owner
```

To get category blogline pass `category` param:

```ruby
user.blogline :category => category
community.blogline :category => category
```

More examples you can find in this
[spec](https://github.com/salkar/inkwell/blob/master/test/dummy/spec/functional/category_spec.rb)

## License
Inkwell is Copyright © 2013 Sergey Sokolov. It is free software, and may be
redistributed under the terms specified in the MIT-LICENSE file.

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/ca9e83bea0d6c79d5909780eb805e944 "githalytics.com")](http://githalytics.com/salkar/inkwell)

