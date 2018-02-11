# frozen_string_literal: true

class CreateInkwellFavorites < ActiveRecord::Migration[5.0]
  def change
    create_table :inkwell_favorites do |t|
      t.integer :favorite_subject_id
      t.string :favorite_subject_type
      t.integer :favorite_object_id
      t.string :favorite_object_type

      t.timestamps
    end
    add_index :inkwell_favorites,
              [:favorite_subject_id, :favorite_subject_type],
              name: "inkwell_favorites_subject_index"
    add_index :inkwell_favorites,
              [:favorite_object_id, :favorite_object_type],
              name: "inkwell_favorites_object_index"
  end
end
