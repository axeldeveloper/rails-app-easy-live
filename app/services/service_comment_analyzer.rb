# frozen_string_literal: true

# Service para analisar comentários
#
# @author axel
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

      translated = ServiceLibreTranslate.translate(comment.body)
      Rails.logger.info "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      Rails.logger.info "Executing CommentAnalyzer "
      Rails.logger.info translated
      Rails.logger.info comment.body

      puts "DEBUG - translated: #{translated.inspect}"
      puts "DEBUG - Original: #{comment.body.inspect}"


      comment.translated = translated

      keywords = Keyword.pluck(:word)
      # count = keywords.count { |word| translated&.downcase&.include?(word.downcase) }
      # count = keywords.count { |word| translated.downcase.include?(word.downcase) }

      # Versão robusta e limpa
      translated_text = (translated || "").to_s.strip.downcase
      filtered_keywords = keywords.compact.map(&:to_s).reject(&:empty?)

      count = filtered_keywords.count do |word|
        translated_text.include?(word.strip.downcase)
      end



      if count >= 2
        comment.aprovar!
      else
        comment.rejeitar!
      end

      comment.save!
    end
  end
end
