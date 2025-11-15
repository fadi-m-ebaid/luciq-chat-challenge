class UpdateChatsCountJob < ApplicationJob
  queue_as :default

  def perform
    Application.find_each do |application|
      count = application.chats.count
      application.update_column(:chats_count, count)
      Rails.logger.info "Updated chats_count for application #{application.token}: #{count}"
    end
  end
end
