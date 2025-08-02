class UserMetric < ApplicationRecord
  belongs_to :user

  def recalculate!
    comments = user.comments.processando

    return reset_metrics! if comments.empty?

    approved = comments.approved
    comment_lengths = comments.map { |c| c.translated&.length || 0 }

    update!(
      total_comments: comments.count,
      approved_comments: approved.count,
      rejected_comments: comments.rejected.count,
      approval_rate: calculate_approval_rate(approved.count, comments.count),
      avg_comment_length: comment_lengths.mean.round(2),
      median_comment_length: comment_lengths.median.round(2),
      std_dev_comment_length: comment_lengths.standard_deviation.round(2),
      additional_metrics: calculate_additional_metrics(comments, comment_lengths)
    )
  end

  private

  def reset_metrics!
    update!(
      total_comments: 0,
      approved_comments: 0,
      rejected_comments: 0,
      approval_rate: 0.0,
      avg_comment_length: 0.0,
      median_comment_length: 0.0,
      std_dev_comment_length: 0.0,
      additional_metrics: {}
    )
  end

  def calculate_approval_rate(approved, total)
    return 0.0 if total.zero?
    ((approved.to_f / total) * 100).round(2)
  end

  def calculate_additional_metrics(comments, lengths)
    {
      max_comment_length: lengths.max || 0,
      min_comment_length: lengths.min || 0,
      total_characters: lengths.sum,
      avg_words_per_comment: comments.map(&:word_count).mean.round(2),
      comments_per_post: (comments.count.to_f / user.posts.count).round(2)
    }
  end
end
