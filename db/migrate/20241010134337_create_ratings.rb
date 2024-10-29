class CreateRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :ratings do |t|
      t.float :number
      t.references :ratingable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
