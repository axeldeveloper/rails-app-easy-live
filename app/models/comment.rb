class Comment < ApplicationRecord
  include AASM

  belongs_to :post
  has_one :user, through: :post

  # Adicionar callbacks para logging
  aasm column: :status, whiny_transitions: false do
    state :novo, initial: true
    state :processando
    state :aprovado
    state :rejeitado

    event :processar do
      transitions from: :novo, to: :processando

      after do
        Rails.logger.info "Comment #{id} transitioned to processando"
      end
    end

    event :aprovar do
      transitions from: :processando, to: :aprovado

      after do
        Rails.logger.info "Comment #{id} approved"
        # update_user_metrics
        # trigger_group_metrics_update
      end
    end

    event :rejeitar do
      transitions from: :processando, to: :rejeitado

      after do
        Rails.logger.info "Comment #{id} rejected"
        # update_user_metrics
        # trigger_group_metrics_update
      end
    end
  end


  scope :aprovado, -> { where(status: "aprovado") }
  scope :rejeitado, -> { where(status: "rejeitado") }
  scope :processando, -> { where(status: [ "aprovado", "rejeitado" ]) }


  # Método helper para verificar se pode ser reprocessado
  def can_be_reprocessed?
    novo? || (processando? && updated_at < 1.hour.ago)
  end

  # Método para resetar para estado inicial (admin only)
  def reset_to_novo!
    update_column(:status, "novo") if persisted?
  end


   def translated_text
     translated.presence || body
   end

  # def word_count
  #   return 0 unless translated_text
  #   translated_text.split(/\s+/).length
  # end

  # def character_count
  #   return 0 unless translated_text
  #   translated_text.length
  # end

  private

  def update_user_metrics
    UserMetricsCalculatorJob.perform_async(post.user_id)
  end

  def trigger_group_metrics_update
    GroupMetricsCalculatorJob.perform_async
  end
end
