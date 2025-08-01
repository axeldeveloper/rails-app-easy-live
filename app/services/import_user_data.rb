class ImportUserData
    include HTTParty
    base_uri 'https://jsonplaceholder.typicode.com'
    default_timeout 10 # Adiciona timeout para evitar requisições travadas
  
    class ApiError < StandardError; end
  
    def self.call(username)
      user_data = fetch_user(username)
      return unless user_data
  
      ActiveRecord::Base.transaction do
        Rails.logger.info 'Inicio da transation '
        local_user = create_or_update_user(user_data)
        import_posts_for_user(local_user, user_data["id"])
        local_user # Retorna o usuário criado/atualizado
      end
    rescue ApiError => e
      Rails.logger.error "Failed to import user data: #{e.message}"
      nil
    end
  
    private
  
    # Métodos de busca na API
    def self.fetch_user(username)
      # ?username=Bret
      response = handle_errors { get("/users", query: { username: username }) }
      Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ '
      Rails.logger.info 'Executing USER DATA SERVICE '
      Rails.logger.info response
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
      Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ '
      Rails.logger.info 'Executing create_or_update_user '
      Rails.logger.info user_data

      User.find_or_create_by!(external_id: user_data["id"]) do |user|
        user.assign_attributes(
          name: user_data["name"]
        )
      end
    end
  
    def self.create_or_update_post(local_user, post_data)
      local_user.posts.find_or_create_by!(external_id: post_data["id"]) do |post|
        post.assign_attributes(
          title: post_data["title"],
          body: post_data["body"],
        )
      end
    end
  

    def self.create_or_update_comment(post, comment_data)
      post.comments.find_or_create_by!(external_id: comment_data["id"]) do |comment|
        comment.assign_attributes(
          body: comment_data["body"],
          status: 'novo'
        )
      end
    end
  
    # Métodos de importação em lote
    def self.import_posts_for_user(local_user, user_id)
      Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ '
      Rails.logger.info 'Executing import_posts_for_user '
      Rails.logger.info local_user
      Rails.logger.info user_id
      posts_data = fetch_posts(user_id)
      posts_data.each do |post_data|
        post = create_or_update_post(local_user, post_data)
        import_comments_for_post(post, post_data["id"])
      end
    end
  
    def self.import_comments_for_post(post, post_id)
      comments_data = fetch_comments(post_id)
      comments_data.each do |comment_data|
        comment = create_or_update_comment(post, comment_data)
        ProcessCommentJob.perform_later(comment.id) if comment.persisted?
      end
    end
  
    # Tratamento de erros
    def self.handle_errors
      response = yield
      raise ApiError, "API request failed with status #{response.code}" unless response.success?
      response
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      raise ApiError, "Request timeout: #{e.message}"
      Rails.logger.info e.message
    rescue SocketError => e
      raise ApiError, "Connection failed: #{e.message}"
      Rails.logger.info e.message

    end
  end