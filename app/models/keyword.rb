class Keyword < ApplicationRecord
    # validates :word, presence: true, uniqueness: true
    validates :word, presence: true, uniqueness: { case_sensitive: false }

    scope :active, -> { where(active: true) }

    before_save :normalize_word

    after_commit :trigger_reprocessing, if: :should_trigger_reprocessing?

    def self.active_words
        Rails.cache.fetch("active_keywords", expires_in: 1.hour) do
            active.pluck(:word).map(&:downcase)
        end
    end

    def self.clear_cache
        Rails.cache.delete("active_keywords")
    end

    def normalize_word
        self.word = word.strip.downcase
    end

    def should_trigger_reprocessing?
        (saved_change_to_word? || saved_change_to_active?) && active?
    end

    def trigger_reprocessing
        self.class.clear_cache
        ReprocessAllCommentsJob.perform_async
    end
end
