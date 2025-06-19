class CreateEffectEffectPrograms < ActiveRecord::Migration[7.2]
  def change
    create_table :effect_effect_programs do |t|
      t.references :effect, null: false, foreign_key: true
      t.references :effect_program, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :effect_effect_programs, [:effect_id, :effect_program_id], unique: true
  end
end 