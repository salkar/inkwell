# This migration comes from inkwell (originally 20130212130858)
class RefactorCommentTable < ActiveRecord::Migration
  def change
    rename_column :inkwell_comments, "#{::Inkwell::Engine::config.post_table.to_s.singularize}_id", :topmost_obj_id
    add_column :inkwell_comments, :topmost_obj_type, :string
    ::Inkwell::Comment.update_all :topmost_obj_type => 'p'
  end
end