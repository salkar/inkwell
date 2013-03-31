class Category < ActiveRecord::Base
  attr_accessible :name

  acts_as_inkwell_category
end
