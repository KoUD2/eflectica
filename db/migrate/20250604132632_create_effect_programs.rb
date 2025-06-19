class CreateEffectPrograms < ActiveRecord::Migration[7.2]
  def change
    create_table :effect_programs do |t|
      t.string :name

      t.timestamps
    end
  end
end
