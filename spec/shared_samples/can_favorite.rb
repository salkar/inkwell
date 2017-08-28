require 'rails_helper'

RSpec.shared_examples_for 'can_favorite' do
  let(:owner){create(described_class.to_s.underscore.to_sym)}
  let(:post){create(:post)}

  context 'relation' do
    context 'inkwell_favorites' do
      let!(:favorite) do
        create(:inkwell_favorite, favorite_subject: owner, favorite_object: post)
      end

      it 'should be returned' do
        expect(owner.inkwell_favorites).to eq([favorite])
      end
    end
  end

  context 'favorite' do
    it 'should be done' do
      expect(Inkwell::Favorite.count).to eq(0)
      result = owner.favorite(post)
      expect(Inkwell::Favorite.count).to eq(1)
      favorite = Inkwell::Favorite.first
      expect(result).to eq(favorite)
      {favorite_subject: owner, favorite_object: post}.each do |k, v|
        expect(favorite.public_send(k)).to eq(v)
      end
    end
  end
end
