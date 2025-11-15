namespace :elasticsearch do
  desc "Create Elasticsearch index for messages"
  task create_index: :environment do
    Message.__elasticsearch__.create_index! force: true
    puts "Created Elasticsearch index for messages"
  end

  desc "Index all existing messages"
  task index_all: :environment do
    Message.import force: true
    puts "Indexed #{Message.count} messages"
  end

  desc "Delete Elasticsearch index"
  task delete_index: :environment do
    Message.__elasticsearch__.delete_index!
    puts "Deleted Elasticsearch index"
  end
end
