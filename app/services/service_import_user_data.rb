class ServiceImportUserData
    include HTTParty

    base_uri "https://jsonplaceholder.typicode.com"
    default_timeout 10

    class ApiError < StandardError; end

    def self.call(username, import_job_id = nil)
      imported_comments = []
      @import_job = ImportJob.find_by(id: import_job_id) if import_job_id

      update_progress("Finding user...")
      user_data = fetch_user(username)
      return unless user_data

      ActiveRecord::Base.transaction do
        Rails.logger.info "Inicio da transacao"
        local_user = create_or_update_user(user_data)
        imported_comments = import_posts_for_user(local_user, user_data["id"])


        update_progress("Calculating metrics...")
        local_user.user_metric.recalculate!
        GroupMetric.current.recalculate!

        local_user.update!(status: "completed")
        @import_job&.complete!
        local_user
      end

      # DEPOIS da transação, enfileirar os jobs
      enqueue_comment_processing_jobs(imported_comments)

    rescue ApiError => e
      Rails.logger.error "Failed to import user data: #{e.message}"
      nil
    end

    private

    # Métodos de busca na API
    def self.fetch_user(username)
      response = handle_errors { get("/users", query: { username: username }) }
      Rails.logger.info "Executing fetch_user: #{response.first}"
      response.first
    end

    def self.fetch_posts(user_id)
      handle_errors { get("/posts", query: { userId: user_id }) }
    end

    def self.fetch_comments(post_id)
      handle_errors { get("/comments", query: { postId: post_id }) }
    end

    # Métodos de criação/atualização
    def self.create_or_update_user(user_data)
      update_progress("Creating user record...")
      Rails.logger.info "Executing create_or_update_user: #{user_data['name']}"

      User.find_or_create_by!(external_id: user_data["id"]) do |user|
        user.assign_attributes(username: user_data["username"])
      end
    end

    def self.create_or_update_post(local_user, post_data)
      local_user.posts.find_or_create_by!(external_id: post_data["id"]) do |post|
        post.assign_attributes(
          title: post_data["title"],
          body: post_data["body"]
        )
      end
    end

    def self.create_or_update_comment(post, comment_data)
      return nil if comment_data["id"].blank?

      comment = post.comments.find_or_initialize_by(external_id: comment_data["id"])

      comment.assign_attributes(
        body: comment_data["body"]&.strip,
        status: comment.new_record? ? "novo" : comment.status
      )

      comment.save!
      comment
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Erro ao criar/atualizar comment #{comment_data['id']}: #{e.message}"
      nil
    end

    # Métodos de importação em lote - RETORNA array de comment IDs
    def self.import_posts_for_user(local_user, user_id)
      Rails.logger.info "Executing import_posts_for_user for user: #{local_user.id}"
      update_progress("Importing posts...")
      comment_ids = []
      posts_data = fetch_posts(user_id)

      posts_data.each do |post_data|
        post = create_or_update_post(local_user, post_data)
        post_comment_ids = import_comments_for_post(post, post_data["id"])
        comment_ids.concat(post_comment_ids)
      end

      comment_ids.compact
    end

    def self.import_comments_for_post(post, post_id)
      update_progress("Processing comments...")
      comment_ids = []
      comments_data = fetch_comments(post_id)

      comments_data.each do |comment_data|
        comment = create_or_update_comment(post, comment_data)
        comment_ids << comment.id if comment&.persisted?
      end

      comment_ids
    end

    # Enfileirar jobs APÓS a transação
    def self.enqueue_comment_processing_jobs(comment_ids)
      return if comment_ids.empty?

      Rails.logger.info "Enfileirando #{comment_ids.size} jobs de processamento"

      comment_ids.each do |comment_id|
        # Delay opcional para garantir que o commit foi processado
        ProcessCommentJob.set(wait: 2.seconds).perform_later(comment_id)
      end
    end

    # Tratamento de erros
    def self.handle_errors
      response = yield
      raise ApiError, "API request failed with status #{response.code}" unless response.success?
      response
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      Rails.logger.error "Request timeout: #{e.message}"
      raise ApiError, "Request timeout: #{e.message}"
    rescue SocketError => e
      Rails.logger.error "Connection failed: #{e.message}"
      raise ApiError, "Connection failed: #{e.message}"
    end

    def self.update_progress(message)
      return unless @import_job

      @import_job.increment_progress!
      @import_job.update(progress_data: { current_step: message })
    end
end
