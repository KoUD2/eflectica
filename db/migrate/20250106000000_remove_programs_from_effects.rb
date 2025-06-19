class RemoveProgramsFromEffects < ActiveRecord::Migration[7.2]
  def change
    remove_column :effects, :programs, :string
  end
end 