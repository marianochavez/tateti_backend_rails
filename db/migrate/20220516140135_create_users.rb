class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :password_digest
      t.boolean :enabled, default: true
      t.string :token

      t.timestamps
    end
  end
end
