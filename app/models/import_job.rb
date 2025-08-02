# app/models/import_job.rb
class ImportJob < ApplicationRecord
  validates :username, presence: true

  def progress_percentage
    return 0 if total_steps.zero?
    ((completed_steps.to_f / total_steps) * 100).round(2)
  end

  def increment_progress!
    increment!(:completed_steps)
  end

  def complete!
    update!(status: "completed", completed_steps: total_steps)
  end

  def fail!(error)
    update!(status: "failed", error_message: error.to_s)
  end
end
