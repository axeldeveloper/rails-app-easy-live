class Api::V1::BaseController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found(exception)
    render json: {
      status: 'error',
      message: 'Resource not found',
      error: exception.message
    }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: {
      status: 'error',
      message: 'Validation failed',
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def bad_request(exception)
    render json: {
      status: 'error',
      message: 'Bad request',
      error: exception.message
    }, status: :bad_request
  end
end 