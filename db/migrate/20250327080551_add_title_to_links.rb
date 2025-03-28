class AddTitleToLinks < ActiveRecord::Migration[7.2]
  def change
    add_column :links, :title, :string
  end
end
