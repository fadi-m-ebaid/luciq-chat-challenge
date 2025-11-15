class Api::V1::ChatsController < ApplicationController
  before_action :set_application
  before_action :set_chat, only: [:show]

  def create
    number = $redis.incr("app:#{@application.token}:chats_counter")
    CreateChatJob.perform_later(@application.id, number)
    render json: {number: number}, status: :accepted
  end

  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i

    page = 1 if page < 1
    per_page = 20 if per_page < 1
    per_page = 100 if per_page > 100


    offset = (page - 1) * per_page

    total_chats = @application.chats_count
    total_pages = (total_chats / per_page.to_f).ceil

    if page > total_pages && total_chats > 0
      return render json: {
        chats: [],
        pagination: {
          current_page: page,
          per_page: per_page,
          total_pages: total_pages,
          total_chats: total_chats,
          next_page: nil,
          prev_page: (page > 1 ? page - 1 : nil)
        }
      }
    end

    chats = @application.chats.select(:number, :messages_count, :created_at, :updated_at).order(number: :asc).limit(per_page).offset(offset)

    render json: {
      chats: chats.map { |chat|
        {
          number: chat.number,
          messages_count: chat.messages_count,
          created_at: chat.created_at,
          updated_at: chat.updated_at
        }
      },
      pagination: {
        current_page: page,
        per_page: per_page,
        total_pages: total_pages,
        total_chats: total_chats,
        next_page: (page < total_pages ? page + 1 : nil),
        prev_page: (page > 1 ? page - 1 : nil)
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
