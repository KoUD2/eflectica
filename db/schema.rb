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

ActiveRecord::Schema[7.2].define(version: 2024_10_06_135018) do
  create_table "assets", force: :cascade do |t|
    t.string "name"
    t.string "img"
    t.text "description"
    t.text "devices"
    t.text "manual"
    t.string "link_to"
    t.boolean "is_secure"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "asset_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_collections_on_asset_id"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_favorites_on_asset_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "title"
    t.text "media"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.float "number"
    t.string "retingable_type", null: false
    t.integer "retingable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["retingable_type", "retingable_id"], name: "index_ratings_on_retingable"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.text "bio"
    t.string "contact"
    t.string "portfolio"
    t.integer "speed"
    t.boolean "is_admin"
    t.string "avatar"
    t.string "email"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "assets", "users"
  add_foreign_key "collections", "assets"
  add_foreign_key "collections", "users"
  add_foreign_key "favorites", "assets"
  add_foreign_key "favorites", "users"
  add_foreign_key "questions", "users"
end
