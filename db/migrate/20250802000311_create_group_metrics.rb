class CreateGroupMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :group_metrics do |t|
      t.integer :total_users, default: 0
      t.integer :total_comments, default: 0
      t.integer :total_approved_comments, default: 0
      t.integer :total_rejected_comments, default: 0
      t.float :overall_approval_rate, default: 0.0
      t.float :avg_user_approval_rate, default: 0.0
      t.float :median_user_approval_rate, default: 0.0
      t.float :std_dev_user_approval_rate, default: 0.0
      t.json :additional_metrics

      t.timestamps
    end
  end
end
