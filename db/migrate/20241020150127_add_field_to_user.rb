class AddFieldToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :username, :string
    add_column :users, :bio, :text
    add_column :users, :contact, :string
    add_column :users, :portfolio, :string
    add_column :users, :is_admin, :boolean, default: false
    add_column :users, :avatar, :string
  end
end
