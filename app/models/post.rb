class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, inverse_of: false
end
