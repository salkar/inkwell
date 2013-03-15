module Inkwell
  class Following < ActiveRecord::Base
    attr_accessible :followed_id, :follower_id

    belongs_to :following, :foreign_key => :followed_id
    belongs_to :follower, :foreign_key => :follower_id
  end
end