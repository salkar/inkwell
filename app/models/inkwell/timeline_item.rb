module Inkwell
  class TimelineItem < ActiveRecord::Base
    attr_accessible :item_id, :owner_id, :from_source, :has_many_sources, :item_type, :created_at, :updated_at, :owner_type
  end
end
