# frozen_string_literal: true

require "rails_helper"

RSpec.describe "readme" do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post) { create(:post) }
  let(:other_post) { create(:post) }

  context "favorites for viewer" do
    it "should work" do
      user.favorite(post)
      user.favorite(other_post)
      other_user.favorite(other_post)
      result = user.favorites(for_viewer: other_user)
      expect(result.detect { |item| item == post }.favorited_in_timeline).to eq(false)
      expect(result.detect { |item| item == other_post }.favorited_in_timeline).to eq(true)
    end
  end
end
