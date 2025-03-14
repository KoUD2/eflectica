class AddImageTypeToImages < ActiveRecord::Migration[7.2]
  def change
    add_column :images, :image_type, :string
  end
end
