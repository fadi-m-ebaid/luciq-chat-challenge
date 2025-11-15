namespace :counters do
  desc "Update all chats_count for applications"
  task update_chats: :environment do
    puts "Updating chats_count..."
    UpdateChatsCountJob.perform_now
    puts "Done!"
  end

  desc "Update all messages_count for chats"
  task update_messages: :environment do
    puts "Updating messages_count..."
    UpdateMessagesCountJob.perform_now
    puts "Done!"
  end

  desc "Update all counters (chats and messages)"
  task update_all: :environment do
    Rake::Task['counters:update_chats'].invoke
    Rake::Task['counters:update_messages'].invoke
  end
end
