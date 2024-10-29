class CreateCollectionEffects < ActiveRecord::Migration[7.2]
  def change
    create_table :collection_effects do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :effect, null: false, foreign_key: true

      t.timestamps
    end
  end
end
