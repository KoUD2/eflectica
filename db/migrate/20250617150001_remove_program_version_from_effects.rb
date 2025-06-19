class RemoveProgramVersionFromEffects < ActiveRecord::Migration[7.0]
  def change
    remove_column :effects, :program_version, :string
  end
end 