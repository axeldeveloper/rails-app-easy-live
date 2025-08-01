# frozen_string_literal: true
# Service para analisar comentários
#
# @author [your_name]
#
# @param comment_id [Integer] ID do comentário a ser analisado
#
# @return [void]
#
class ServiceCommentAnalyzer
  class << self
    def call(comment_id)
      comment = Comment.find_by(id: comment_id)
      return unless comment  # Para o processamento aqui se não encontrar
      
      comment.processar!
  
      translated = LibreTranslateService.translate(comment.body)
      Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ '
      Rails.logger.info 'Executing CommentAnalyzer '
      Rails.logger.info translated
      Rails.logger.info comment.body
      
      
      comment.translated = translated
  
      keywords = Keyword.pluck(:word)
      count = keywords.count { |word| translated.downcase.include?(word.downcase) }
  
      if count >= 2
        comment.aprovar!
      else
        comment.rejeitar!
      end
  
      comment.save!
    end
  end
end
  