class UserMetricsCalculatorJob < ApplicationJob
  queue_as :default
  # include Sidekiq::Job

  def perform(user_id)
    user = User.find(user_id)
    user.user_metric.recalculate!

    # Trigger group metrics update
    GroupMetricsCalculatorJob.perform_async
  end
end
