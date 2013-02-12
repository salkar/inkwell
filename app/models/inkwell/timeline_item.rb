module Inkwell
  class TimelineItem < ActiveRecord::Base
    attr_accessible :item_id, :user_id, :from_source, :has_many_sources, :item_type, :created_at, :updated_at
    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize
  end
end
