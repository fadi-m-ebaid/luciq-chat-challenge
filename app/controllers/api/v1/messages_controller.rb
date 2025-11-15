class Api::V1::MessagesController < ApplicationController
  before_action :set_application
  before_action :set_chat
  before_action :set_message, only: [:show]

  def create
    unless params[:body].present?
      return render json: {error: "Body parameter is required"}, status: :bad_request
    end
    number = $redis.incr("app:#{@application.token}:chat:#{@chat.number}:messages_counter")
    CreateMessageJob.perform_later(@chat.id, number, params[:body])
    render json: {message_number: number}, status: :accepted
  end

  def index
    messages =@chat.messages.select(:number, :body, :created_at, :updated_at)
    render json: messages.map { |msg|
      {
        number: msg.number,
        body: msg.body,
        created_at: msg.created_at,
        updated_at: msg.updated_at
      }
    }
  end

  def show
    render json: {
      number: @message.number,
      body: @message.body,
      created_at: @message.created_at,
      updated_at: @message.updated_at
    }
  end

  def search
    query = params[:q]

    unless query.present?
      return render json: {error: "Search query parameter 'q' is required"}, status: :bad_request
    end

    search_result = Message.search(
      query:{
        bool:{
          must: [
            {match: {body: query}}
          ],
          filter: [
            {term: {chat_id: @chat.id}}
          ]
        }
      }
    )

    messages =search_result.records.to_a

    render json: messages.map{ |msg|
      {
        number: msg.number,
        body: msg.body,
        created_at: msg.created_at,
        updated_at: msg.updated_at
      }
    }
  end

  private

  def set_application
    @application = Application.find_by!(token: params[:application_token])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Application not found' }, status: :not_found
  end

  def set_chat
    @chat = @application.chats.find_by!(number: params[:chat_number])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Chat not found' }, status: :not_found
  end

  def set_message
    @message = @chat.messages.find_by!(number: params[:number])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Message not found' }, status: :not_found
  end
end
