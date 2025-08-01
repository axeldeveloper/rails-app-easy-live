class Api::V1::UsersController < Api::V1::BaseController
  # before_action :set_user, only: [:show, :update, :destroy]

 

  # POST /api/v1/users
  def create
    username = params[:username]
    ImportUserJob.perform_later(username)
    render json: { status: "processing", username: username }, status: :accepted
  end

  

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :external_id)
  end
end 