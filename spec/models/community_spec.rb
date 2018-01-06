require 'rails_helper'

RSpec.describe Community, type: :model do
  it_behaves_like 'can_favorite'
  it_behaves_like 'can_blogging'
  it_behaves_like 'can_reblog'
end
