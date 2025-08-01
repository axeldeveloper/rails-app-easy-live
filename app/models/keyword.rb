class Keyword < ApplicationRecord
    validates :word, presence: true, uniqueness: true
end
  
