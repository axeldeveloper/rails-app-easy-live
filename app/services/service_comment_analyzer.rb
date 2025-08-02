# frozen_string_literal: true

# Service para analisar comentários
#
# @author axel
#
# @param comment_id [Integer] ID do comentário a ser analisado
#
# @return [void]
class ServiceCommentAnalyzer
  class << self
    def call(comment_id)
      Rails.logger.info "=" * 50
      comment = Comment.find_by(id: comment_id)
      unless comment
        Rails.logger.warn "Comment #{comment_id} not found - skipping processing"
        return
      end

      # Verificar se o comentário pode ser processado
      unless comment.may_processar?
        Rails.logger.warn "Comment #{comment_id} cannot be processed. Current state: #{comment.status}"
        return
      end

      # Usar transação para garantir consistência
      ActiveRecord::Base.transaction do
        # Transição para processando
        comment.processar!

        # Executar análise
        result = analyze_comment(comment)

        # Aplicar resultado da análise
        apply_analysis_result(comment, result)

        Rails.logger.info "Comment #{comment_id} processed successfully"
      end
      Rails.logger.info "=" * 50
    rescue AASM::InvalidTransition => e
      Rails.logger.error "AASM transition error for comment #{comment_id}: #{e.message}"
      handle_transition_error(comment, e)
      # Re-raise para que o Sidekiq possa fazer retry se necessário
      raise e
    rescue StandardError => e
      Rails.logger.error "Error processing comment #{comment_id}: #{e.message}"
      rollback_to_safe_state(comment)
      # Re-raise para que o Sidekiq possa fazer retry
      raise e
    end

    private

    def analyze_comment(comment)
      # translated = ServiceLibreTranslate.translate(comment.body)

      translated = ServiceMyMemoryTranslate.translate(comment.body)

      begin

        # Tentar diferentes métodos
        if translated.present?
          success = comment.update_column(:translated, translated) ||
                   comment.update_attribute(:translated, translated) ||
                   (comment.translated = translated && comment.save!(validate: false))

          Rails.logger.info "Translation saved successfully: #{success}"
        else
          Rails.logger.warn "Translation is blank - not saving"
        end

        Rails.logger.info "Comment translated after: #{comment.reload.translated.inspect}"
      rescue => e
        Rails.logger.error "Failed to update translated column: #{e.message}"
        Rails.logger.error e.backtrace.first(5).join("\n")
        # Continuar processamento mesmo se não conseguir salvar a tradução
      end


      # Análise de palavras-chave
      keywords = Keyword.pluck(:word)
      translated_text = sanitize_text(translated)
      filtered_keywords = sanitize_keywords(keywords)

      count = count_matching_keywords(translated_text, filtered_keywords)

      Rails.logger.info "Keywords found: #{count}/#{filtered_keywords.size}"

      {
        keyword_count: count,
        should_approve: count >= 2,
        translated_text: translated
      }
    end

    def apply_analysis_result(comment, result)
      if result[:should_approve]
        transition_to_approved(comment)
      else
        transition_to_rejected(comment)
      end
    end

    def transition_to_approved(comment)
      if comment.may_aprovar?
        comment.aprovar!
        Rails.logger.info "Comment #{comment.id} approved successfully"
      else
        Rails.logger.warn "Comment #{comment.id} cannot be approved from state: #{comment.status}"
        raise AASM::InvalidTransition, "Cannot approve from #{comment.status}"
      end
    end

    def transition_to_rejected(comment)
      if comment.may_rejeitar?
        comment.rejeitar!
        Rails.logger.info "Comment #{comment.id} rejected successfully"
      else
        Rails.logger.warn "Comment #{comment.id} cannot be rejected from state: #{comment.status}"
        raise AASM::InvalidTransition, "Cannot reject from #{comment.status}"
      end
    end

    def sanitize_text(text)
      (text || "").to_s.strip.downcase
    end

    def sanitize_keywords(keywords)
      keywords.compact.map(&:to_s).map(&:strip).reject(&:empty?)
    end

    def count_matching_keywords(text, keywords)
      keywords.count { |word| text.include?(word.downcase) }
    end

    def handle_transition_error(comment, error)
      # Tentar voltar para um estado seguro se possível
      rollback_to_safe_state(comment)
    end

    def rollback_to_safe_state(comment)
      return unless comment&.persisted?

      # Se não conseguir fazer transições, pelo menos logar o estado atual
      Rails.logger.error "Comment #{comment.id} stuck in state: #{comment.status}"

      # Para Sidekiq: deixar o job falhar para retry automático
      # O Sidekiq vai tentar novamente baseado na configuração de retry
    end
  end
end
