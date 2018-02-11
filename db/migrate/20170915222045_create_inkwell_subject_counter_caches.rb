# frozen_string_literal: true

class CreateInkwellSubjectCounterCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :inkwell_subject_counter_caches do |t|
      t.integer :cached_subject_id
      t.string :cached_subject_type
      t.integer :favorite_count, default: 0
      t.integer :blog_item_count, default: 0
      t.integer :reblog_count, default: 0
      t.integer :comment_count, default: 0
      t.integer :follower_count, default: 0
      t.integer :following_count, default: 0

      t.timestamps
    end

    add_index :inkwell_subject_counter_caches,
              [:cached_subject_id, :cached_subject_type],
              name: "inkwell_subject_counter_cache_index"
  end
end
