class Comment < ApplicationRecord
  include AASM

  belongs_to :post

  aasm column: :status do
    state :novo, initial: true
    state :processando
    state :aprovado
    state :rejeitado

    event :processar do
      transitions from: :novo, to: :processando
    end

    event :aprovar do
      transitions from: :processando, to: :aprovado
    end

    event :rejeitar do
      transitions from: :processando, to: :rejeitado
    end
  end
end

