class AddSpeedToAssets < ActiveRecord::Migration[7.2]
  def change
    add_column :assets, :speed, :integer
  end
end
