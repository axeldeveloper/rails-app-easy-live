class Api::V1::ProgressController < Api::V1::BaseController
  # GET /api/v1/progress/:id
  def show
    import_job = ImportJob.find(params[:id])

    render json: {
      id: import_job.id,
      username: import_job.username,
      status: import_job.status,
      progress_percentage: import_job.progress_percentage,
      completed_steps: import_job.completed_steps,
      total_steps: import_job.total_steps,
      current_step: import_job.progress_data&.dig("current_step"),
      error_message: import_job.error_message,
      created_at: import_job.created_at,
      updated_at: import_job.updated_at
    }
  end

  # GET /api/v1/progress
  def index
    import_jobs = ImportJob.order(created_at: :desc).limit(50)

    render json: {
      import_jobs: import_jobs.map do |job|
        {
          id: job.id,
          username: job.username,
          status: job.status,
          progress_percentage: job.progress_percentage,
          created_at: job.created_at,
          updated_at: job.updated_at
        }
      end
    }
  end
end
