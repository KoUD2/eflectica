class CreateCollectionLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :collection_links do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :link, null: false, foreign_key: true

      t.timestamps
    end
  end
end
