class Community < ActiveRecord::Base
  attr_accessible :name, :owner_id, :public

  acts_as_inkwell_community
end
