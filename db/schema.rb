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

ActiveRecord::Schema[8.0].define(version: 2026_01_29_155948) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "candidate_stages", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.bigint "stage_id", null: false
    t.date "entered_at"
    t.date "exited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id"], name: "index_candidate_stages_on_candidate_id"
    t.index ["stage_id"], name: "index_candidate_stages_on_stage_id"
  end

  create_table "candidates", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_stage_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.date "started_at"
    t.date "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviewers", force: :cascade do |t|
    t.bigint "candidate_stage_id", null: false
    t.integer "phase"
    t.date "decided_at"
    t.text "feedback"
    t.integer "order"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_stage_id"], name: "index_reviewers_on_candidate_stage_id"
    t.index ["user_id"], name: "index_reviewers_on_user_id"
  end

  create_table "stages", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_id"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "post_id", null: false
    t.boolean "is_ended", default: false
    t.index ["parent_id"], name: "index_stages_on_parent_id"
    t.index ["post_id"], name: "index_stages_on_post_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "candidate_stages", "candidates"
  add_foreign_key "candidate_stages", "stages"
  add_foreign_key "reviewers", "candidate_stages"
  add_foreign_key "reviewers", "users"
  add_foreign_key "stages", "posts"
  add_foreign_key "stages", "stages", column: "parent_id"
end
