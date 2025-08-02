class CreateUserMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :user_metrics do |t|
      t.integer :total_comments, default: 0
      t.integer :approved_comments, default: 0
      t.integer :rejected_comments, default: 0
      t.float :approval_rate, default: 0.0
      t.float :avg_comment_length, default: 0.0
      t.float :median_comment_length, default: 0.0
      t.float :std_dev_comment_length, default: 0.0
      t.json :additional_metrics

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
