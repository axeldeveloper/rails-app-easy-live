# app/jobs/import_user_job.rb
class ImportUserJob < ApplicationJob
    queue_as :default
  
    def perform(username)
      ImportUserData.call(username)
    end
end