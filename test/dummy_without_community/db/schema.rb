# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130331123647) do

  create_table "inkwell_blog_items", :force => true do |t|
    t.integer  "item_id"
    t.boolean  "is_reblog"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "owner_id"
    t.string   "item_type"
    t.string   "owner_type"
  end

  create_table "inkwell_comments", :force => true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.integer  "parent_comment_id"
    t.integer  "topmost_obj_id"
    t.text     "upper_comments_tree"
    t.text     "users_ids_who_favorite_it", :default => "[]"
    t.text     "users_ids_who_comment_it",  :default => "[]"
    t.text     "users_ids_who_reblog_it",   :default => "[]"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "topmost_obj_type"
  end

  create_table "inkwell_favorite_items", :force => true do |t|
    t.integer  "item_id"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "item_type"
    t.string   "owner_type"
  end

  create_table "inkwell_followings", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "inkwell_timeline_items", :force => true do |t|
    t.integer  "item_id"
    t.integer  "owner_id"
    t.text     "from_source",      :default => "[]"
    t.boolean  "has_many_sources", :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "item_type"
    t.string   "owner_type"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.text     "users_ids_who_favorite_it", :default => "[]"
    t.text     "users_ids_who_comment_it",  :default => "[]"
    t.text     "users_ids_who_reblog_it",   :default => "[]"
  end

  create_table "users", :force => true do |t|
    t.string   "nick"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "follower_count",  :default => 0
    t.integer  "following_count", :default => 0
  end

end
