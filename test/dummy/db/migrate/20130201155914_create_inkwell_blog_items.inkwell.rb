# This migration comes from inkwell (originally 20121209121955)
class CreateInkwellBlogItems < ActiveRecord::Migration
  def change
      create_table :inkwell_blog_items do |t|
        t.integer :item_id
        t.integer :owner_id
        t.boolean :is_owner_user
        t.boolean :is_reblog
        t.boolean :is_comment

        t.timestamps
      end
  end
end
