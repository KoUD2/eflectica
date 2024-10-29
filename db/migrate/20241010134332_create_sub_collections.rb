class CreateSubCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :sub_collections do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
