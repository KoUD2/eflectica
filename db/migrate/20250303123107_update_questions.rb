class UpdateQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :platform, :text
    add_column :questions, :programs, :string
    add_column :questions, :link_to, :string
    remove_column :questions, :media, :text
  end
end
