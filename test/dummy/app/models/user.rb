class User < ActiveRecord::Base
  attr_accessible :nick
  has_many :posts, :dependent => :destroy

  acts_as_inkwell_user

end
