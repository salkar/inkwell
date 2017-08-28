require 'rails_helper'

module Inkwell
  RSpec.describe Favorite, type: :model do
    let(:post){create(:post)}
    let(:user){create(:user)}

    context 'relation' do
      let(:favorite){create(:inkwell_favorite, favorite_subject: user, favorite_object: post)}

      context 'favorite_subject' do
        it 'should be returned' do
          expect(favorite.favorite_subject).to eq(user)
        end
      end

      context 'favorite_object' do
        it 'should be returned' do
          expect(favorite.favorite_object).to eq(post)
        end
      end
    end
  end
end
