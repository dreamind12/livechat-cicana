class GuestPushSubscription < ApplicationRecord
  belongs_to :account
  belongs_to :conversation

  validates :endpoint, presence: true
  validates :p256dh, presence: true
  validates :auth, presence: true

  validates :endpoint,
            uniqueness: {
              scope: :conversation_id
            }
end