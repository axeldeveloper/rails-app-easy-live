FactoryBot.define do
  factory :user_metric do
    total_comments { 1 }
    approved_comments { 1 }
    rejected_comments { 1 }
    user { nil }
  end
end
