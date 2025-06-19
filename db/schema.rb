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

ActiveRecord::Schema[7.2].define(version: 2025_06_19_130100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "collection_effects", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "effect_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_effects_on_collection_id"
    t.index ["effect_id"], name: "index_collection_effects_on_effect_id"
  end

  create_table "collection_images", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "image_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_images_on_collection_id"
    t.index ["image_id"], name: "index_collection_images_on_image_id"
  end

  create_table "collection_links", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "link_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_collection_links_on_collection_id"
    t.index ["link_id"], name: "index_collection_links_on_link_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "private"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.bigint "effect_id", null: false
    t.index ["effect_id"], name: "index_comments_on_effect_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "effect_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "effect_effect_categories", force: :cascade do |t|
    t.bigint "effect_id", null: false
    t.bigint "effect_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect_category_id"], name: "index_effect_effect_categories_on_effect_category_id"
    t.index ["effect_id", "effect_category_id"], name: "idx_on_effect_id_effect_category_id_47e47d0298", unique: true
    t.index ["effect_id"], name: "index_effect_effect_categories_on_effect_id"
  end

  create_table "effect_effect_programs", force: :cascade do |t|
    t.bigint "effect_id", null: false
    t.bigint "effect_program_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect_id", "effect_program_id"], name: "idx_on_effect_id_effect_program_id_0839fbb240", unique: true
    t.index ["effect_id"], name: "index_effect_effect_programs_on_effect_id"
    t.index ["effect_program_id"], name: "index_effect_effect_programs_on_effect_program_id"
  end

  create_table "effect_effect_tasks", force: :cascade do |t|
    t.bigint "effect_id", null: false
    t.bigint "effect_task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect_id", "effect_task_id"], name: "index_effect_effect_tasks_on_effect_id_and_effect_task_id", unique: true
    t.index ["effect_id"], name: "index_effect_effect_tasks_on_effect_id"
    t.index ["effect_task_id"], name: "index_effect_effect_tasks_on_effect_task_id"
  end

  create_table "effect_programs", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "effect_tasks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "effects", force: :cascade do |t|
    t.string "name"
    t.string "img"
    t.text "description"
    t.integer "speed"
    t.text "platform"
    t.text "manual"
    t.string "link_to"
    t.string "is_secure"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_effects_on_user_id"
  end

  create_table "favorite_images", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "notes"
    t.string "image_url"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_favorite_images_on_user_id"
  end

  create_table "favorite_links", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "notes"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_favorite_links_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "effect_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect_id"], name: "index_favorites_on_effect_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "imageable_type", null: false
    t.bigint "imageable_id", null: false
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_type"
    t.string "title"
    t.text "description"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "likeable_type", null: false
    t.bigint "likeable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "links", force: :cascade do |t|
    t.string "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
  end

  create_table "news_feeds", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "effect_id", null: false
    t.bigint "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_news_feeds_on_collection_id"
    t.index ["effect_id"], name: "index_news_feeds_on_effect_id"
    t.index ["user_id"], name: "index_news_feeds_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.float "number"
    t.string "ratingable_type", null: false
    t.bigint "ratingable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["ratingable_type", "ratingable_id"], name: "index_ratings_on_ratingable"
  end

  create_table "sub_collections", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.bigint "user_id", null: false
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
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
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

  create_table "user_effect_categories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "effect_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect_category_id"], name: "index_user_effect_categories_on_effect_category_id"
    t.index ["user_id"], name: "index_user_effect_categories_on_user_id"
  end

  create_table "user_effect_programs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "effect_program_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["effect_program_id"], name: "index_user_effect_programs_on_effect_program_id"
    t.index ["user_id"], name: "index_user_effect_programs_on_user_id"
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
    t.string "jti"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collection_effects", "collections"
  add_foreign_key "collection_effects", "effects"
  add_foreign_key "collection_images", "collections"
  add_foreign_key "collection_images", "images"
  add_foreign_key "collection_links", "collections"
  add_foreign_key "collection_links", "links"
  add_foreign_key "collections", "users"
  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "effects"
  add_foreign_key "comments", "users"
  add_foreign_key "effect_effect_categories", "effect_categories"
  add_foreign_key "effect_effect_categories", "effects"
  add_foreign_key "effect_effect_programs", "effect_programs"
  add_foreign_key "effect_effect_programs", "effects"
  add_foreign_key "effect_effect_tasks", "effect_tasks"
  add_foreign_key "effect_effect_tasks", "effects"
  add_foreign_key "effects", "users"
  add_foreign_key "favorite_images", "users"
  add_foreign_key "favorite_links", "users"
  add_foreign_key "favorites", "effects"
  add_foreign_key "favorites", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "news_feeds", "collections"
  add_foreign_key "news_feeds", "effects"
  add_foreign_key "news_feeds", "users"
  add_foreign_key "sub_collections", "collections"
  add_foreign_key "sub_collections", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "user_effect_categories", "effect_categories"
  add_foreign_key "user_effect_categories", "users"
  add_foreign_key "user_effect_programs", "effect_programs"
  add_foreign_key "user_effect_programs", "users"
end
