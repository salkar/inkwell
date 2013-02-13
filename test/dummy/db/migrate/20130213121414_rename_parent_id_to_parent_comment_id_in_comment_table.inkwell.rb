# This migration comes from inkwell (originally 20130212130868)
class RenameParentIdToParentCommentIdInCommentTable < ActiveRecord::Migration
  def change
    rename_column :inkwell_comments, :parent_id, :parent_comment_id
  end
end