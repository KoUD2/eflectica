class CreateCollectionImages < ActiveRecord::Migration[7.2]
  def change
    create_table :collection_images do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
