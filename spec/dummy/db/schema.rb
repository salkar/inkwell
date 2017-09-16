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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170915222045) do

  create_table "comments", force: :cascade do |t|
    t.integer "post_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "communities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inkwell_favorites", force: :cascade do |t|
    t.integer "favorite_subject_id"
    t.string "favorite_subject_type"
    t.integer "favorite_object_id"
    t.string "favorite_object_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favorite_object_id", "favorite_object_type"], name: "inkwell_favorites_object_index"
    t.index ["favorite_subject_id", "favorite_subject_type"], name: "inkwell_favorites_subject_index"
  end

  create_table "inkwell_object_counter_caches", force: :cascade do |t|
    t.integer "cached_object_id"
    t.string "cached_object_type"
    t.integer "favorite_count", default: 0
    t.integer "reblog_count", default: 0
    t.integer "comment_count", default: 0
    t.index ["cached_object_id", "cached_object_type"], name: "inkwell_object_counter_cache_index"
  end

  create_table "inkwell_subject_counter_caches", force: :cascade do |t|
    t.integer "cached_subject_id"
    t.string "cached_subject_type"
    t.integer "favorite_count", default: 0
    t.integer "blog_item_count", default: 0
    t.integer "reblog_count", default: 0
    t.integer "comment_count", default: 0
    t.integer "follower_count", default: 0
    t.integer "following_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cached_subject_id", "cached_subject_type"], name: "inkwell_subject_counter_cache_index"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
