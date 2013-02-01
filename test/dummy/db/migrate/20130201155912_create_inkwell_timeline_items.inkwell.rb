# This migration comes from inkwell (originally 20121202140510)
class CreateInkwellTimelineItems < ActiveRecord::Migration
  def change
    create_table :inkwell_timeline_items do |t|
      t.integer :item_id
      t.integer "#{::Inkwell::Engine::config.user_table.to_s.singularize}_id"
      t.string :from_source
      t.boolean :has_many_sources, :default => false
      t.boolean :is_comment

      t.timestamps
    end
  end
end
