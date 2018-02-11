# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  it_behaves_like "can_be_favorited"
  it_behaves_like "can_be_reblogged"
end
