class GroupMetric < ApplicationRecord
  def self.current
    last || create!
  end

  def recalculate!
    users = User.processed.includes(:user_metric)
    user_metrics = users.map(&:user_metric).compact

    return reset_metrics! if user_metrics.empty?

    approval_rates = user_metrics.map(&:approval_rate)
    total_comments = user_metrics.sum(&:total_comments)
    total_approved = user_metrics.sum(&:approved_comments)

    update!(
      total_users: users.count,
      total_comments: total_comments,
      total_approved_comments: total_approved,
      total_rejected_comments: user_metrics.sum(&:rejected_comments),
      overall_approval_rate: calculate_overall_approval_rate(total_approved, total_comments),
      avg_user_approval_rate: approval_rates.mean.round(2),
      median_user_approval_rate: approval_rates.median.round(2),
      std_dev_user_approval_rate: approval_rates.standard_deviation.round(2),
      additional_metrics: calculate_additional_metrics(user_metrics, users)
    )
  end

  private

  def reset_metrics!
    update!(
      total_users: 0,
      total_comments: 0,
      total_approved_comments: 0,
      total_rejected_comments: 0,
      overall_approval_rate: 0.0,
      avg_user_approval_rate: 0.0,
      median_user_approval_rate: 0.0,
      std_dev_user_approval_rate: 0.0,
      additional_metrics: {}
    )
  end

  def calculate_overall_approval_rate(approved, total)
    return 0.0 if total.zero?
    ((approved.to_f / total) * 100).round(2)
  end

  def calculate_additional_metrics(user_metrics, users)
    avg_lengths = user_metrics.map(&:avg_comment_length)
    {
      avg_comments_per_user: (user_metrics.sum(&:total_comments).to_f / users.count).round(2),
      avg_posts_per_user: (users.sum { |u| u.posts.count }.to_f / users.count).round(2),
      avg_comment_length_across_users: avg_lengths.mean.round(2),
      median_comment_length_across_users: avg_lengths.median.round(2)
    }
  end
end
