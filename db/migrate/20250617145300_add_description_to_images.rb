class AddDescriptionToImages < ActiveRecord::Migration[7.2]
  def change
    add_column :images, :description, :text
  end
end
