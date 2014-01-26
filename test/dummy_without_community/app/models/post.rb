class Post < ActiveRecord::Base
  belongs_to :user

  acts_as_inkwell_post
end
