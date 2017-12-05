class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.string :title
      t.text :description
      t.integer :status, index: true, default: 0
      t.integer :owner_id, index: true
      t.integer :assigned_to_id, index: true
      t.datetime :closed_at

      t.timestamps
    end
  end
end
