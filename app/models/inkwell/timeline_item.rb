module Inkwell
  class TimelineItem < ActiveRecord::Base
    belongs_to ::Inkwell::Engine::config.user_table.to_s.singularize
  end
end
