class AddVersionToEffectPrograms < ActiveRecord::Migration[7.0]
  def change
    add_column :effect_programs, :version, :string
  end
end 