class GroupMetricsCalculatorJob < ApplicationJob
  queue_as :default
  # include Sidekiq::Job

  def perform
    GroupMetric.current.recalculate!
  end
end
