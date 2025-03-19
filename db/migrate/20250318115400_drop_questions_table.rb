class DropQuestionsTable < ActiveRecord::Migration[7.2]
  def up
    drop_table :questions
  end
  
  def down
    create_table :questions do |t|
      t.string "title"
      t.text "description"
      t.integer "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "platform"
      t.string "programs"
      t.string "link_to"
      t.string "is_secure"
      t.index ["user_id"], name: "index_questions_on_user_id"
    end
  end
  
end
