class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages, dependent: :destroy
  validates :number, presence: true, uniqueness: { scope: :application_id}
  validates :application_id, presence: true
end
