# frozen_string_literal: true

# Job para processar comentários
#
# @author Axel
#
# @param comment_id [Integer] ID do comentário a ser processado
#
# @return [void]
#
# app/jobs/process_comment_job.rb
#


class ProcessCommentJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5, backtrace: true

  # Retry customizado para aguardar o comentário aparecer
  sidekiq_retry_in do |count, exception|
    if exception.is_a?(CommentNotFoundError) && count < 3
      # Aguardar mais tempo a cada tentativa
      [ 10, 30, 60 ][count].seconds
    else
      :kill # Para outros erros, não fazer retry
    end
  end

  def perform(comment_id)
    comment = Comment.find_by(id: comment_id)

    if comment.nil?
      # Aguardar um pouco e tentar novamente
      sleep(5)
      comment = Comment.find_by(id: comment_id)

      if comment.nil?
        raise CommentNotFoundError, "Comment #{comment_id} not found after waiting"
      end
    end

    ServiceCommentAnalyzer.call(comment_id)
  end
end

# Exception customizada
class CommentNotFoundError < StandardError; end
