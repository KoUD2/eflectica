class AddParentIdToComments < ActiveRecord::Migration[7.2]
  def change
    add_column :comments, :parent_id, :integer
    add_index :comments, :parent_id
    add_foreign_key :comments, :comments, column: :parent_id, on_delete: :cascade
  end
end
