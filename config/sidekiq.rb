require 'sidekiq/web'

Sidekiq::Web.set :sessions, false  # Ignora sessões (não necessário para APIs stateless)
Sidekiq::Web.disable :protection   # ⚠️ Desativa CSRF (CUIDADO: NÃO use em produção!)