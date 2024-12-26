class CreateNewsFeeds < ActiveRecord::Migration[7.2]
  def change
    create_table :news_feeds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :effect, null: false, foreign_key: true
      t.references :collection, null: false, foreign_key: true

      t.timestamps
    end
  end
end
