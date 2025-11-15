require 'elasticsearch/model'

class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks


  belongs_to :chat
  validates :number, presence: true, uniqueness: { scope: :chat_id }
  validates :body, presence: true
  validates :chat_id, presence: true

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :body, type: 'text', analyzer: 'standard'
      indexes :number, type: 'integer'
      indexes :chat_id, type: 'integer'
      indexes :created_at, type: 'date'
    end
  end

  def as_indexed_json(options = {})
    {
      body: body,
      number: number,
      chat_id: chat_id,
      created_at: created_at
    }
  end
end
