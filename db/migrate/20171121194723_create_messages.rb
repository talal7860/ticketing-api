class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.integer :ticket_id
      t.integer :sender_id
      t.text :content

      t.timestamps
    end
  end
end
