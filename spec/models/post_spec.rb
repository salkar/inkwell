require 'rails_helper'

RSpec.describe Post, type: :model do
  it_behaves_like 'can_be_favorited'
  it_behaves_like 'can_be_blogged'
  it_behaves_like 'can_be_reblogged'
end
