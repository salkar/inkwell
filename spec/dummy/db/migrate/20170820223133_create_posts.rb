class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.timestamps
    end
    add_index :posts, :user_id
  end
end
