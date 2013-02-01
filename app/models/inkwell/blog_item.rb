module Inkwell
  class BlogItem < ActiveRecord::Base
    attr_accessible :item_id, :owner_id, :is_reblog, :is_comment, :created_at, :updated_at, :is_owner_user
  end
end
