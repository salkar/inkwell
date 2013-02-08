# This migration comes from inkwell (originally 20121209121955)
class CreateInkwellBlogItems < ActiveRecord::Migration
  def change
      create_table :inkwell_blog_items do |t|
        t.integer :item_id
        t.integer "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
        t.boolean :is_reblog
        t.boolean :is_comment

        t.timestamps
      end
  end
end
