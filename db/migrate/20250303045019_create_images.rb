class CreateImages < ActiveRecord::Migration[7.2]
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true, null: false
      t.string :file

      t.timestamps
    end
  end
end
