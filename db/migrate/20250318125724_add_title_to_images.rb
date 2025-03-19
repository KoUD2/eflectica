class AddTitleToImages < ActiveRecord::Migration[7.2]
  def change
    add_column :images, :title, :string
  end
end
