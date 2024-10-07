class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username
      t.text :bio
      t.string :contact
      t.string :portfolio
      t.integer :speed
      t.boolean :is_admin
      t.string :avatar
      t.string :email
      t.string :password

      t.timestamps
    end
  end
end
