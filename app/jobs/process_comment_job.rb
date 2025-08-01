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
class ProcessCommentJob < ApplicationJob
    queue_as :default
  
    def perform(comment_id)
      ServiceCommentAnalyzer.call(comment_id)
    end
  end