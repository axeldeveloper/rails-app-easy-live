require "sidekiq/web"

Sidekiq::Web.set :sessions, false  # Ignora sessões (não necessário para APIs stateless)
Sidekiq::Web.disable :protection   # ⚠️ Desativa CSRF (CUIDADO: NÃO use em produção!)


# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.death_handlers << ->(job, ex) do
    # Quando um job falha definitivamente após todos os retries
    if job["class"] == "CommentAnalyzerJob"
      comment_id = job["args"].first
      Rails.logger.error "CommentAnalyzerJob permanently failed for comment #{comment_id}"

      # Opcional: notificar admin ou resetar comentário
      # AdminNotifier.job_failed(job, ex)
    end
  end
end
