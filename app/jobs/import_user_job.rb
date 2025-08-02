# app/jobs/import_user_job.rb
# Job para importar dados de usuário
#
# @author Axel
#
# @param username [String] Nome de usuário a ser importado
#
# @return [void]
class ImportUserJob < ApplicationJob
    queue_as :default

    def perform(username, import_job_id = nil)
      # import_job = ImportJob.find_by(id: import_job_id) if import_job_id

      ServiceImportUserData.call(username, import_job_id)
    rescue StandardError => e
      # Log adicional para o job
      Rails.logger.error "ImportUserJob failed  #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Re-raise para que o Sidekiq gerencie o retry
      raise e
    end
end
