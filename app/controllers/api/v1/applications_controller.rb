class Api::V1::ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :update]

  def create
    @application = Application.new(application_params)
    if @application.save
      render json:{
        token: @application.token,
        name: @application.name,
        chats_count: @application.chats_count
      }, status: :created
    else
      render json: {errors: @application.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render json: {
      token: @application.token,
      name: @application.name,
      chats_count: @application.chats_count,
      created_at: @application.created_at,
      updated_at: @application.updated_at
    }
  end

  def update
    if @application.update(application_params)
      render json:{
        token: @application.token,
        name: @application.name,
        chats_count: @application.chats_count 
      }
    else
      render json: {errors: @application.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render json: {error: "Application not found"}, statues: :not_found
  end

  def application_params
    params.require(:application).permit(:name)
  end
end
