# frozen_string_literal: true

class CreateInkwellBlogItems < ActiveRecord::Migration[5.1]
  def change
    create_table :inkwell_blog_items do |t|
      t.integer :blog_item_subject_id
      t.string :blog_item_subject_type
      t.integer :blog_item_object_id
      t.string :blog_item_object_type
      t.boolean :reblog, default: false

      t.timestamps
    end
    add_index :inkwell_blog_items,
              [:blog_item_subject_id, :blog_item_subject_type],
              name: "inkwell_blog_item_subject_index"
    add_index :inkwell_blog_items,
              [:blog_item_object_id, :blog_item_object_type],
              name: "inkwell_blog_item_object_index"
  end
end
