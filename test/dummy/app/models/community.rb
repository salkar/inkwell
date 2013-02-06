class Community < ActiveRecord::Base
  attr_accessible :name, :owner_id

  acts_as_inkwell_community
end
