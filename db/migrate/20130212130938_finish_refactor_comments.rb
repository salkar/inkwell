class FinishRefactorComments < ActiveRecord::Migration
  def change
    remove_column :inkwell_comments, :users_ids_who_favorite_it
    remove_column :inkwell_comments, :users_ids_who_comment_it
    remove_column :inkwell_comments, :users_ids_who_reblog_it
  end
end