class RemoveSpeedFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :speed, :integer
  end
end
