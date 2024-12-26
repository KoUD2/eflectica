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

ActiveRecord::Schema[7.2].define(version: 2024_12_24_152037) do
  create_table "collection_effects", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "effect_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_effects_on_collection_id"
    t.index ["effect_id"], name: "index_collection_effects_on_effect_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "effects", force: :cascade do |t|
    t.string "name"
    t.string "img"
    t.text "description"
    t.integer "speed"
    t.text "devices"
    t.text "manual"
    t.string "link_to"
    t.boolean "is_secure"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "programs"
    t.index ["user_id"], name: "index_effects_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "effect_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect_id"], name: "index_favorites_on_effect_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "news_feeds", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "effect_id", null: false
    t.integer "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_news_feeds_on_collection_id"
    t.index ["effect_id"], name: "index_news_feeds_on_effect_id"
    t.index ["user_id"], name: "index_news_feeds_on_user_id"
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
    t.string "ratingable_type", null: false
    t.integer "ratingable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["ratingable_type", "ratingable_id"], name: "index_ratings_on_ratingable"
  end

  create_table "sub_collections", force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_sub_collections_on_collection_id"
    t.index ["user_id"], name: "index_sub_collections_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.text "bio"
    t.string "contact"
    t.string "portfolio"
    t.boolean "is_admin", default: false
    t.string "avatar"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "collection_effects", "collections"
  add_foreign_key "collection_effects", "effects"
  add_foreign_key "collections", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "effects", "users"
  add_foreign_key "favorites", "effects"
  add_foreign_key "favorites", "users"
  add_foreign_key "news_feeds", "collections"
  add_foreign_key "news_feeds", "effects"
  add_foreign_key "news_feeds", "users"
  add_foreign_key "questions", "users"
  add_foreign_key "sub_collections", "collections"
  add_foreign_key "sub_collections", "users"
  add_foreign_key "taggings", "tags"
end
