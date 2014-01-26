module Inkwell
  class Following < ActiveRecord::Base
    belongs_to :following, :foreign_key => :followed_id
    belongs_to :follower, :foreign_key => :follower_id
  end
end