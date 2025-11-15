class CreateMessageJob < ApplicationJob
  queue_as :default

  def perform(chat_id, number, body)
    chat = Chat.find(chat_id)
    
    message = chat.messages.create!(
      number: number,
      body: body
    )
    
    Rails.logger.info "Created message ##{message.number} for chat #{chat.id}"
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create message: #{e.message}"
    raise
  end
end
