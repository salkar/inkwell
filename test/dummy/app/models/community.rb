class Community < ActiveRecord::Base
  attr_accessible :name

  acts_as_inkwell_community
end
