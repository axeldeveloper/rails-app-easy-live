# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_02_000423) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string "body"
    t.text "translated"
    t.string "status"
    t.bigint "post_id", null: false
    t.integer "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "group_metrics", force: :cascade do |t|
    t.integer "total_users", default: 0
    t.integer "total_comments", default: 0
    t.integer "total_approved_comments", default: 0
    t.integer "total_rejected_comments", default: 0
    t.float "overall_approval_rate", default: 0.0
    t.float "avg_user_approval_rate", default: 0.0
    t.float "median_user_approval_rate", default: 0.0
    t.float "std_dev_user_approval_rate", default: 0.0
    t.json "additional_metrics"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "import_jobs", force: :cascade do |t|
    t.string "username"
    t.string "status", default: "pending"
    t.integer "total_steps", default: 0
    t.integer "completed_steps", default: 0
    t.text "error_message"
    t.json "progress_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keywords", force: :cascade do |t|
    t.string "word"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word"], name: "index_keywords_on_word", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.bigint "user_id", null: false
    t.integer "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "user_metrics", force: :cascade do |t|
    t.integer "total_comments", default: 0
    t.integer "approved_comments", default: 0
    t.integer "rejected_comments", default: 0
    t.float "approval_rate", default: 0.0
    t.float "avg_comment_length", default: 0.0
    t.float "median_comment_length", default: 0.0
    t.float "std_dev_comment_length", default: 0.0
    t.json "additional_metrics"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_metrics_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.integer "external_id"
    t.string "status", default: "active"
    t.string "string", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "comments", "posts"
  add_foreign_key "posts", "users"
  add_foreign_key "user_metrics", "users"
end
