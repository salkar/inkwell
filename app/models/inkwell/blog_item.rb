module Inkwell
  class BlogItem < ActiveRecord::Base
    attr_accessible :item_id, :owner_id, :is_reblog, :item_type, :created_at, :updated_at, :owner_type
  end
end
