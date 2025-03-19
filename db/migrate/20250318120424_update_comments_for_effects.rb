class UpdateCommentsForEffects < ActiveRecord::Migration[7.2]
  def change
    remove_column :comments, :commentable_type, :string
    remove_column :comments, :commentable_id, :integer

    add_reference :comments, :effect, null: false, foreign_key: true
  end
end
