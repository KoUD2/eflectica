class CreateEffectEffectTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :effect_effect_tasks do |t|
      t.references :effect, null: false, foreign_key: true
      t.references :effect_task, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :effect_effect_tasks, [:effect_id, :effect_task_id], unique: true
  end
end 