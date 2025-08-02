class CreateKeywords < ActiveRecord::Migration[8.0]
  def change
    create_table :keywords do |t|
      t.string :word
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :keywords, :word, unique: true
  end
end
