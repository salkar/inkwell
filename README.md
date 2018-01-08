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

##### Inkwell::CanFavorite#favorite(obj)

```ruby
  user.favorite(post)
```

After that `post` will appear in the `user.favorites`. Also if `user`
sees `post` in someone else's timelines (or blog, favorites, etc.),
`post` will have `favorited_in_timeline` attribute with `true` value.

##### Inkwell::CanFavorite#unfavorite(obj)

```ruby
  user.unfavorite(post)
```

Rolls back `favorite` effects.

##### Inkwell::CanFavorite#favorite?(obj)

```ruby
  user.favorite?(post)
  #=> false
  user.favorite(post)
  #=> true
  user.favorite?(post)
  #=> true
```

Check that `post` is added to favorites or not.

*Notice: if `obj` passed to `favorite`, `unfavorite` or `favorite?` does not
include `Inkwell::CanBeFavorited` `Inkwell::Errors::NotFavoritable` will
be raised*

##### Inkwell::CanFavorite#favorites(for_viewer: nil, &block)

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
