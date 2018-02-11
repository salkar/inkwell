# frozen_string_literal: true

class CreateInkwellObjectCounterCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :inkwell_object_counter_caches do |t|
      t.integer :cached_object_id
      t.string :cached_object_type
      t.integer :favorite_count, default: 0
      t.integer :reblog_count, default: 0
      t.integer :comment_count, default: 0
    end

    add_index :inkwell_object_counter_caches,
              [:cached_object_id, :cached_object_type],
              name: "inkwell_object_counter_cache_index"
  end
end
