class AddStatusToCollections < ActiveRecord::Migration[7.2]
  def change
    add_column :collections, :status, :string, default: 'private'
  end
end
