class UserBoard < ActiveRecord::Migration[7.0]
  def change
    create_table :users_boards do |t|
      t.belongs_to :user
      t.belongs_to :board

      t.timestamps
    end
  end
end
