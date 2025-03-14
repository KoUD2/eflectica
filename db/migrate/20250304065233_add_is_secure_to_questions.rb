class AddIsSecureToQuestions < ActiveRecord::Migration[7.2]
  def change
    add_column :questions, :is_secure, :string
  end
end
