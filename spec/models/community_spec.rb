require 'rails_helper'

RSpec.describe Community, type: :model do
  it_behaves_like 'can_favorite'
end
