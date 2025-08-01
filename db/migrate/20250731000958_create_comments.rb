class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.string :body
      t.text :translated
      t.string :status
      t.references :post, null: false, foreign_key: true
      t.integer :external_id

      t.timestamps
    end
  end
end
