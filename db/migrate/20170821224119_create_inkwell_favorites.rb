class CreateInkwellFavorites < ActiveRecord::Migration[5.0]
  def change
    create_table :inkwell_favorites do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :favorited_id
      t.string :favorited_type

      t.timestamps
    end
    add_index :inkwell_favorites, [:owner_id, :owner_type]
    add_index :inkwell_favorites, [:favorited_id, :favorited_type]
  end
end
