class CreateUserTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :user_tokens do |t|
      t.string :token, index: true
      t.integer :user_id, index: true

      t.timestamps
    end
  end
end
