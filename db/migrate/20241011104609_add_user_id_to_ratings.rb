class AddUserIdToRatings < ActiveRecord::Migration[7.2]
  def change
    add_column :ratings, :user_id, :integer
  end
end
