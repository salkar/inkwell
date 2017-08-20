class CreatePosts < Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end
