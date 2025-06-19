class CreateEffectEffectCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :effect_effect_categories do |t|
      t.references :effect, null: false, foreign_key: true
      t.references :effect_category, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :effect_effect_categories, [:effect_id, :effect_category_id], unique: true
  end
end 