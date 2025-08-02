class User < ApplicationRecord
    has_many :posts
    has_many :comments, through: :posts,  inverse_of: false
    has_one :user_metric, dependent: :destroy

    validates :username, presence: true
    validates :external_id, presence: true

    scope :processed, -> { where(status: "completed") }

    after_create :create_user_metric

    private

    def create_user_metric
        UserMetric.create!(user: self)
    end
end
