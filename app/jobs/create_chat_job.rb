class CreateChatJob < ApplicationJob
  queue_as :default

  def perform(application_id, number)
    application = Application.find(application_id)

    chat = application.chats.create!(number: number)

    Rails.logger.info "Created chat ##{chat.number} for application #{application.token}, applicatioin name: #{application.name}"
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create chat for application #{application.token}: #{e.message}"
    raise
  end
end
