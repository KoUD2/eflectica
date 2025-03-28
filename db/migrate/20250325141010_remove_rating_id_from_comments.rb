class RemoveRatingIdFromComments < ActiveRecord::Migration[7.2]
  def change
    remove_column :comments, :rating_id, :integer
  end
end
