class AddRatingToComments < ActiveRecord::Migration[7.2]
  def change
    add_reference :comments, :rating, null: false, foreign_key: true
  end
end
