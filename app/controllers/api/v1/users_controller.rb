class Api::V1::UsersController < Api::V1::BaseController
  # before_action :set_user, only: [:show, :update, :destroy]



  # POST /api/v1/users
  def create
    username = params[:username]
    if username.blank?
      return render json: { error: "Username is required" }, status: :bad_request
    end

    # Check if user already exists and is processed
    existing_user = User.find_by(username: username)
    if existing_user&.status == "completed"
      return render json: build_user_response(existing_user), status: :ok
    end


    # Create import job for progress tracking
    import_job = ImportJob.create!(username: username, status: "running")


    ImportUserJob.perform_later(username, import_job.id)

    render json: {
      message: "User import started",
      status: "processing",
      import_job_id: import_job.id,
      progress_url: "/api/v1/progress/#{import_job.id}",
      username: username
    }, status: :accepted
  end

  # GET /api/v1/users/:username
  def show
    user = User.find_by!(username: params[:username])


    if user.status != "completed"
      return render json: { error: "User import not completed yet" }, status: :accepted
    end

    render json: build_user_response(user)
  end


  private

  def build_user_response(user)
    user_metric = user.user_metric
    group_metric = GroupMetric.current

    {
      user: {
        username: user.username,
        status: user.status,
        created_at: user.created_at,
        posts_count: user.posts.count,
        metrics: {
          total_comments: user_metric.total_comments,
          approved_comments: user_metric.approved_comments,
          rejected_comments: user_metric.rejected_comments,
          approval_rate: user_metric.approval_rate,
          avg_comment_length: user_metric.avg_comment_length,
          median_comment_length: user_metric.median_comment_length,
          std_dev_comment_length: user_metric.std_dev_comment_length,
          additional_metrics: user_metric.additional_metrics
        }
      },
      group_metrics: {
        total_users: group_metric.total_users,
        total_comments: group_metric.total_comments,
        total_approved_comments: group_metric.total_approved_comments,
        total_rejected_comments: group_metric.total_rejected_comments,
        overall_approval_rate: group_metric.overall_approval_rate,
        avg_user_approval_rate: group_metric.avg_user_approval_rate,
        median_user_approval_rate: group_metric.median_user_approval_rate,
        std_dev_user_approval_rate: group_metric.std_dev_user_approval_rate,
        additional_metrics: group_metric.additional_metrics
      },
      keywords: Keyword.active.pluck(:word),
      generated_at: Time.current
    }
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :external_id)
  end
end
