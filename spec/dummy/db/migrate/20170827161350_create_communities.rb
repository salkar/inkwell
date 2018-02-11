# frozen_string_literal: true

class CreateCommunities < ActiveRecord::Migration[5.1]
  def change
    create_table :communities do |t|
      t.timestamps
    end
  end
end
