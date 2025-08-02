class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked, attempts: 3, wait: :exponentially_longer

  discard_on ActiveJob::DeserializationError
end
