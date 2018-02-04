# Inkwell
[![Build Status](https://api.travis-ci.org/salkar/inkwell.svg?branch=master)](https://travis-ci.org/salkar/inkwell)
[![Code Climate](https://codeclimate.com/github/salkar/inkwell/badges/gpa.svg)](https://codeclimate.com/github/salkar/inkwell)
[![Coverage Status](https://coveralls.io/repos/github/salkar/inkwell/badge.svg?branch=master)](https://coveralls.io/github/salkar/inkwell?branch=master)

Inkwell provides a simple way to add social networking features
(e.g., comments, reblogs, favorites, following/followers, communities
and timelines) to your Ruby on Rails application.

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

#### Setup

Include relevant modules to models:
* add `include Inkwell::CanFavorite` to models which instances should
be able to favorite other objects
* add `include Inkwell::CanBeFavorited` to models which instances should
be able to be added to favorites

For sample:

```ruby
# app/models/user.rb

class User < ApplicationRecord
  include Inkwell::CanFavorite
  #...
end

# app/models/post.rb

class Post < ApplicationRecord
  include Inkwell::CanBeFavorited
  #...
end
```

#### Inkwell::CanFavorite usage
<details>
  <summary>Inkwell::CanFavorite#favorite(obj)</summary>
  <p></p>

  ```ruby
  user.favorite(post)
  ```

  After that `post` will appear in the `user.favorites`. Also if `user`
  sees `post` in someone else's timelines (or blog, favorites, etc.),
  `post` will have `favorited_in_timeline` attribute with `true` value.
</details>

<details>
  <summary>Inkwell::CanFavorite#unfavorite(obj)</summary>
  <p></p>

  ```ruby
  user.unfavorite(post)
  ```

  Rolls back `favorite` effects.
</details>

<details>
  <summary>Inkwell::CanFavorite#favorite?(obj)</summary>
  <p></p>

```ruby
user.favorite?(post)
#=> false
user.favorite(post)
#=> true
user.favorite?(post)
#=> true
```

Check that `post` is added to favorites by `user`.

*Notice: if `obj` passed to `favorite`, `unfavorite` or `favorite?` does not
include `Inkwell::CanBeFavorited` `Inkwell::Errors::NotFavoritable` will
be raised*
</details>

<details>
  <summary id="inkwellcanfavoritefavoritesfor_viewer-nil-block">Inkwell::CanFavorite#favorites(for_viewer: nil, &block)</summary>
  <p></p>

  Return array of instances favorited by object.

  ```ruby
  user.favorites
  #=> [#<Post>, #<Comment>, ...]
  ```

  If `favorites` used without block, all favorited objects will be
  returned (without pagination, ordering, etc). In this case `Array` is
  returned not `Relation`!

  For perform operations on relation block should be used:

  ```ruby
  # Gemfile
  gem 'kaminari'

  # code

  user.favorites do |relation|
    relation.page(1).order('created_at DESC')
  end
  #=> [#<Post>, #<Comment>, ...]
  ```

  *Notice: `relation` is relation of Inkwell::Favorite instances (internal
  Inkwell model)*

  *Notice: realization with block looks complicated, but it helps with
  solve troubles with many-to-many relations through other polymorphic
  relations on both sides.*

  If there is necessary to get each result's object with flags for another
  `user` (`favorited_in_timeline`, `reblogged_in_timeline`, etc.),
  `for_viewer` should be passed:

  ```ruby
  user.favorite(post)
  user.favorite(other_post)
  other_user.favorite(other_post)
  result = user.favorites(for_viewer: other_user)
  result.detect{|item| item == post}.favorited_in_timeline
  #=> false
  result.detect{|item| item == other_post}.favorited_in_timeline
  #=> true
  ```
</details>

<details>
  <summary>Inkwell::CanFavorite#favorites_count</summary>
  <p></p>

  ```ruby
  post.favorited_by.each do |obj|
    obj.favorites_count
  end
  ```

  Use `favorites_count` (instead of `obj.favorites.count` or
  `obj.inkwell_favorited.count` for sample) for prevent `n+1` because
  `favorites_count` get counter from inkwell cache included in `favorited_by`
  by default.
</details>

#### Inkwell::CanBeFavorited usage

<details>
  <summary>Inkwell::CanBeFavorited#favorited_by?(subject)</summary>
  <p></p>

  ```ruby
  post.favorited_by?(user)
  #=> false
  user.favorite(post)
  #=> true
  post.favorited_by?(user)
  #=> true
  ```

  Check that `post` is added to favorites by `user`.

  *Notice: if `subject` does not include `Inkwell::CanFavorite`
  `Inkwell::Errors::CannotFavorite` will be raised*
</details>

<details>
  <summary>Inkwell::CanBeFavorited#favorited_count</summary>
  <p></p>

```ruby
user.favorites.each do |obj|
  obj.favorited_count
end
```

Use `favorited_count` (instead of `obj.favorited_by.count` or
`obj.inkwell_favorited.count` for sample) for prevent `n+1` because
`favorites_count` get counter from inkwell cache included in `favorites`
by default.
</details>

<details>
  <summary>Inkwell::CanBeFavorited#favorited_by(&block)</summary>
  <p></p>

  Return array of instances who favorite this object.

  ```ruby
  post.favorited_by
  #=> [#<User>, #<Community>, ...] # Array, NOT Relation
  ```

  ```ruby
  # Gemfile
  gem 'kaminari'

  # code

  user.favorited_by do |relation|
    # relation - Inkwell::Favorite relation
    relation.page(1).order('created_at DESC')
  end
  #=> [#<User>, #<Community>, ...] # Array, NOT Relation
  ```

  *Notice: for more details see
  [Inkwell::CanFavorite#favorites](#inkwellcanfavoritefavoritesfor_viewer-nil-block)
  . It works the same way.*
</details>

### Blogging features

#### Setup

Include relevant modules to models:
* add `include Inkwell::CanBlogging` to models which instances should
be able to add objects to their blog.
* add `include Inkwell::CanBeBlogged` to models which instances should
be able to be added to blogs.

For sample:

```ruby
# app/models/user.rb

class User < ApplicationRecord
  include Inkwell::CanBlogging
  #...
end

# app/models/post.rb

class Post < ApplicationRecord
  include Inkwell::CanBeBlogged
  #...
end
```

To automatically add `posts` to `user` blog, you can do the following:

```
class Post < ApplicationRecord
  include Inkwell::CanBeBlogged
  #...
  belongs_to :user
  #...
  validates :user, presence: true
  #...
  after_create :blog_filling
  #...
  private

  def blog_filling
    user.add_to_blog(self)
  end
end
```

#### Inkwell::CanBlogging usage

<details>
  <summary>Inkwell::CanBlogging#add_to_blog(obj)</summary>
  <p></p>

  ```ruby
  user.add_to_blog(post)
  ```

  After that `post` will appear in the `user.blog`.
</details>

<details>
  <summary>Inkwell::CanBlogging#remove_from_blog(obj)</summary>
  <p></p>

  ```ruby
  user.remove_from_blog(post)
  ```

  Rolls back `add_to_blog` effects.
</details>

<details>
  <summary>Inkwell::CanBlogging#added_to_blog?(obj)</summary>
  <p></p>

  ```ruby
  user.added_to_blog?(post)
  #=> false
  user.add_to_blog(post)
  #=> true
  user.added_to_blog?(post)
  #=> true
  ```

  Check that `post` is added to `user's` blog.

  *Notice: if `obj` passed to `add_to_blog`, `remove_from_blog` or
  `added_to_blog?` does not include `Inkwell::CanBeBlogged`
  `Inkwell::Errors::NotBloggable` will be raised*
</details>

<details>
  <summary>Inkwell::CanBlogging#blog(for_viewer: nil, &block)</summary>
  <p></p>

  Return array of instances blogged and reblogged by object.

  ```ruby
  user.blogs
  #=> [#<Post>, #<Comment>, ...] # array NOT relation
  ```

  ```ruby
  # Gemfile
  gem 'kaminari'

  # code

  user.blogs do |relation|
    # relation - Inkwell::BlogItem relation
    relation.page(1).order('created_at DESC')
  end
  #=> [#<Post>, #<Comment>, ...]
  ```

  Reblogged items has `reblog_in_timeline` flag

  ```ruby
    user.add_to_blog(post)
    user.reblog(other_post)
    result = user.blogs
    result.detect{|item| item == post}.reblog_in_timeline
    #=> false
    result.detect{|item| item == other_post}.reblog_in_timeline
    #=> true
  ```

  If there is necessary to get each result's object with flags for another
  `user` (`reblogged_in_timeline`, `favorited_in_timeline`, etc.),
  `for_viewer` should be passed:

  ```ruby
  user.add_to_blog(post)
  user.add_to_blog(other_post)
  other_user.reblog(other_post)
  result = user.blog(for_viewer: other_user)
  result.detect{|item| item == post}.reblogged_in_timeline
  #=> false
  result.detect{|item| item == other_post}.reblogged_in_timeline
  #=> true
  ```

  *Notice: for more details see
  [Inkwell::CanFavorite#favorites](#inkwellcanfavoritefavoritesfor_viewer-nil-block)
  . It works the same way.*
</details>

<details>
  <summary>Inkwell::CanBlogging#blog_items_count</summary>
  <p></p>

  Return added to blog objects count (including reblogs).

  ```ruby
  user.blog_items_count
  ```

  Use `blog_items_count` for prevent `n+1`.
</details>

#### Inkwell::CanBeBlogged usage

<details>
  <summary>Inkwell::CanBeBlogged#blogged_by?(subject)</summary>
  <p></p>

  ```ruby
  post.blogged_by?(user)
  #=> false
  user.add_to_blog(post)
  #=> true
  post.blogged_by?(user)
  #=> true
  ```

  Check that `post` is added to `user's` blog.

  *Notice: if `subject` does not include `Inkwell::CanBlogging`
  `Inkwell::Errors::CannotBlogging` will be raised*
</details>

<details>
  <summary>Inkwell::CanBeFavorited#blogged_by</summary>
  <p></p>

  Return instance who add to blog this object (owner of this object).

  ```ruby
  user.add_to_blog(post)
  post.blogged_by
  #=> #<User> # user
  ```
</details>

### Reblog features

#### Setup

Include relevant modules to models:
* add `include Inkwell::CanReblog` to models which instances should
be able to reblog objects. If object is reblogged, it is added to
subject's blog.
* add `include Inkwell::CanBeReblogged` to models which instances should
be able to be reblogged.

For sample:

```ruby
# app/models/user.rb

class User < ApplicationRecord
  include Inkwell::CanBlogging
  include Inkwell::CanReblog
  #...
end

# app/models/post.rb

class Post < ApplicationRecord
  include Inkwell::CanBeBlogged
  include Inkwell::CanBeReblogged
  #...
end
```

#### Inkwell::CanReblog usage

<details>
  <summary>Inkwell::CanReblog#reblog(obj)</summary>
  <p></p>

  ```ruby
  user.reblog(post)
  ```

  After that `post` will appear in the `user.blog` as reblog (`reblog_in_timeline` flag).
</details>

<details>
  <summary>Inkwell::CanReblog#unreblog(obj)</summary>
  <p></p>

  ```ruby
  user.unreblog(post)
  ```

  Rolls back `reblog` effects.
</details>

<details>
  <summary>Inkwell::CanReblog#reblog?(obj)</summary>
  <p></p>

  ```ruby
  user.reblog?(post)
  #=> false
  user.reblog(post)
  #=> true
  user.reblog?(post)
  #=> true
  ```

  Check that `post` is reblogged by `user` and added to `user's` blog.

  *Notice: if `obj` passed to `reblog`, `unreblog` or
  `reblog?` does not include `Inkwell::CanBeReblogged`
  `Inkwell::Errors::NotRebloggable` will be raised*
</details>

<details>
  <summary>Inkwell::CanReblog#reblogs_count</summary>
  <p></p>

  Return reblogged objects count.

  ```ruby
  user.reblogs_count
  ```

  Use `reblogs_count` instead of `obj.reblogs.count` or
  `obj.inkwell_reblogs.count` for sample for prevent `n+1`.
</details>

#### Inkwell::CanBeReblogged usage

<details>
  <summary>Inkwell::CanBeReblogged#reblogged_by?(subject)</summary>
  <p></p>

  ```ruby
  post.reblogged_by?(user)
  #=> false
  user.reblog(post)
  #=> true
  post.reblogged_by?(user)
  #=> true
  ```

  Check that `post` is added to `users's` blog as reblog.

  *Notice: if `subject` does not include `Inkwell::CanReblog`
  `Inkwell::Errors::CannotReblog` will be raised*
</details>

<details>
  <summary>Inkwell::CanBeReblogged#reblogged_count</summary>
  <p></p>

```ruby
user.blog.each do |obj|
  obj.try(:reblogged_count) # try is not needed if all objects in blog are rebloggable
end
```

Use `reblogged_count` for prevent `n+1`.
</details>

<details>
  <summary>Inkwell::CanBeReblogged#reblogged_by(&block)</summary>
  <p></p>

  Return array of instances who reblog this object.

  ```ruby
  post.reblogged_by
  #=> [#<User>, #<Community>, ...] # Array, NOT Relation
  ```

  ```ruby
  # Gemfile
  gem 'kaminari'

  # code

  user.reblogged_by do |relation|
    # relation - Inkwell::BlogItem relation
    relation.page(1).order('created_at DESC')
  end
  #=> [#<User>, #<Community>, ...] # Array, NOT Relation
  ```

  *Notice: for more details see
  [Inkwell::CanFavorite#favorites](#inkwellcanfavoritefavoritesfor_viewer-nil-block)
  . It works the same way.*
</details>
