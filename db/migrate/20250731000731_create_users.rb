class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username
      t.integer :external_id
      t.string :status, :string, default: 'active'

      t.timestamps
    end
  end
end
