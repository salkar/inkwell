class Post < ActiveRecord::Base
  attr_accessible :title, :body
  belongs_to :user

  acts_as_inkwell_post
end
