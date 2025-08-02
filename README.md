# Projeto de desafio easy live
- rails 8
- api rest
- sidekiq
- postgres


# Create project
```sh
$ rails new rails-app-easy-live --api -T --database=postgresql
$ cd rails-app-easy-live

$ bundle install

$ gem install foreman

# Ele define comandos que são executados em paralelo com uma única linha de terminal
$ touch Procfile.dev
# is content in file
web: bundle exec rails server -p 3000
worker: bundle exec sidekiq -C config/sidekiq.yml

# ✅ Gerar o modelo
$ rails generate model User name:string external_id:integer:uniq
$ rails generate model Post title:string body:text external_id:integer:uniq user:references
$ rails generate model Comment body:text translated:text status:string external_id:integer:uniq post:references
$ rails generate model Keyword word:string:uniq

rails generate model UserMetrics total_comments:integer approved_comments:integer rejected_comments:integer user:references




$ rails dv:create
$ rails db:migrate
# or
$ rails db:setup



```


# Important  `Create .env file`

```sh
# Database Configuration
POSTGRES_DB=rails_app_easy_live_development
POSTGRES_USER=postgres
POSTGRES_PASSWORD=
DATABASE_URL=

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Rails Configuration
RAILS_ENV=development
RAILS_MASTER_KEY=$(cat config/master.key)

```

# Run - start app
```sh

# run docker compose for redis and  postgresql database
$ docker compose up --build

# run rails app and worker sidekiq
$ foreman start -f Procfile.dev
# OR
$ rails server -p 3000
$ bundle exec sidekiq -C config/sidekiq.yml

```

# Observação

  libretranslate requer uma api paga

  Visit https://portal.libretranslate.com to get an API key