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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150503062207) do

  create_table "challenges", force: :cascade do |t|
    t.text     "en_text",         null: false
    t.text     "ja_text",         null: false
    t.integer  "course_id",       null: false
    t.integer  "sequence_number", null: false
    t.integer  "user_id",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "challenges", ["course_id", "sequence_number"], name: "index_challenges_on_course_id_and_sequence_number", unique: true
  add_index "challenges", ["course_id"], name: "index_challenges_on_course_id"
  add_index "challenges", ["user_id"], name: "index_challenges_on_user_id"

  create_table "courses", force: :cascade do |t|
    t.string   "name",                                  null: false
    t.text     "description"
    t.integer  "level",       limit: 1, default: 0,     null: false
    t.integer  "user_id",                               null: false
    t.integer  "state",       limit: 1, default: 0,     null: false
    t.boolean  "updatable",             default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "courses", ["state"], name: "index_courses_on_state"
  add_index "courses", ["user_id"], name: "index_courses_on_user_id"

  create_table "histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "challenge_id",   null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "unix_timestamp", null: false
  end

  add_index "histories", ["challenge_id"], name: "index_histories_on_challenge_id"
  add_index "histories", ["unix_timestamp", "challenge_id"], name: "index_histories_on_unix_timestamp_and_challenge_id"
  add_index "histories", ["unix_timestamp", "user_id"], name: "index_histories_on_unix_timestamp_and_user_id"
  add_index "histories", ["user_id"], name: "index_histories_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "uid",        null: false
    t.string   "provider",   null: false
    t.string   "name",       null: false
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true

end
