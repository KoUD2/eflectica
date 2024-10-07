class CreateAssets < ActiveRecord::Migration[7.2]
  def change
    create_table :assets do |t|
      t.string :name
      t.string :img
      t.text :description
      t.text :devices
      t.text :manual
      t.string :link_to
      t.boolean :is_secure
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
