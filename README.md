# Projeto de desafio esy live
- rails 8 
- api rest
- sidekiq
- postgres


# create project
rails new rails-app-easy-live --api -T --database=postgresql
cd rails-app-easy-live
bundle install
$ gem install foreman


# Run  Local

# Database Configuration
POSTGRES_DB=rails_app_easy_live_development
POSTGRES_USER=postgres
POSTGRES_PASSWORD=
DATABASE_URL=

# Redis Configuration
REDIS_URL=redis://redis:6379/0

# Rails Configuration
RAILS_ENV=development
RAILS_MASTER_KEY=$(cat config/master.key)
