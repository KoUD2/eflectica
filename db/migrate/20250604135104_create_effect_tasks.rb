class CreateEffectTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :effect_tasks do |t|
      t.string :name

      t.timestamps
    end
  end
end
