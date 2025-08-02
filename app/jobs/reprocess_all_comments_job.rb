class ReprocessAllCommentsJob < ApplicationJob
   queue_as :default
  # include Sidekiq::Job

  def perform
    Rails.logger.info "Starting reprocessing of all comments due to keyword changes"

    # Reset all processed comments to new state
    Comment.where(status: [ "aprovado", "rejeitado" ]).update_all(state: "novo")

    # Reprocess all comments
    Comment.where(status: "novo").find_in_batches(batch_size: 100) do |comments|
      comments.each do |comment|
        ProcessCommentJob.perform_async(comment.id)
      end
    end

    Rails.logger.info "Queued all comments for reprocessing"
  end
end
