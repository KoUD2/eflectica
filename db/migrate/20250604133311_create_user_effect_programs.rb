class CreateUserEffectPrograms < ActiveRecord::Migration[7.2]
  def change
    create_table :user_effect_programs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :effect_program, null: false, foreign_key: true

      t.timestamps
    end
  end
end
