class Api::V1::ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show]

  def create
    number = $redis.incr("app:#{@application.token}:chats_counter")
    CreateChatJob.perform_later(@application.id, number)
    render json: {number: number}, status: :accepted
  end

  def index
    chats = @application.chats.select(:number, :messages_count, :created_at, :updated_at)
    render json: chats.map {|chat|
    {
      number: chat.number,
      messages_count: chat.messages_count,
      created_at: chat.created_at,
      updated_at: chat.updated_at
    }
  }
  end

  def show
    render json: {
      number: @chat.number,
      messages_count: @chat.messages_count,
      created_at: @chat.created_at,
      updated_at: @chat.updated_at
    }
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token])
  rescue ActiveRecord::RecordNotFound
    render json: {error: "Application not found"}, status: :not_found
  end

  def set_chat
    @chat = @application.chats.find_by!(number: params[:number])
  rescue ActiveRecord::RecordNotFound
    render json: {error: "Chat not found"}, status: :not_found
  end
end
