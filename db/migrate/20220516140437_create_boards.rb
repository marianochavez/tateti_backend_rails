class CreateBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :boards do |t|
      t.text :table
      t.integer :state, default: 0
      t.string :turn
      t.string :winner
      t.text :user_1
      t.text :user_2

      t.timestamps
    end
  end
end
