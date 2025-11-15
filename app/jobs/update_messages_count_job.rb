class UpdateMessagesCountJob < ApplicationJob
  queue_as :default

  def perform
    Chat.find_each do |chat|
      count = chat.messages.count
      chat.update_column(:messages_count, count)
      Rails.logger.info "Updated messages_count for chat #{chat.id}: #{count}"
    end
  end
end
