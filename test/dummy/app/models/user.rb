class User < ActiveRecord::Base
  has_many :posts, :dependent => :destroy

  acts_as_inkwell_user

end
