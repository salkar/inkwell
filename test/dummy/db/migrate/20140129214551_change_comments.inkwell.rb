# This migration comes from inkwell (originally 20130212130928)
class ChangeComments < ActiveRecord::Migration
  def change
    rename_column :inkwell_comments, :parent_comment_id, :parent_id
    rename_column :inkwell_comments, :topmost_obj_id, :commentable_id
    rename_column :inkwell_comments, :topmost_obj_type, :commentable_type
    remove_column :inkwell_comments, :upper_comments_tree
    add_column :inkwell_comments, :lft, :integer
    add_column :inkwell_comments, :rgt, :integer
    add_column :inkwell_comments, :depth, :integer
    add_index :inkwell_comments, :parent_id
    add_index :inkwell_comments, :lft
    add_index :inkwell_comments, :rgt
    add_index :inkwell_comments, :user_id
    add_index :inkwell_comments, [:commentable_id, :commentable_type]
    ::Inkwell::Comment.rebuild!
  end
end