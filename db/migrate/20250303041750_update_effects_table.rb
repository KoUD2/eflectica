class UpdateEffectsTable < ActiveRecord::Migration[7.2]
  def change
    change_column :effects, :is_secure, :string

    rename_column :effects, :devices, :platform

    add_column :effects, :program_version, :string
  end
end
