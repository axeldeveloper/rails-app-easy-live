class CreateImportJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :import_jobs do |t|
      t.string :username
      t.string :status, default: 'pending'
      t.integer :total_steps, default: 0
      t.integer :completed_steps, default: 0
      t.text :error_message
      t.json :progress_data

      t.timestamps
    end
  end
end
