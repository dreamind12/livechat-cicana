class CreateGuestPushSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :guest_push_subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true

      t.text :endpoint, null: false
      t.text :p256dh, null: false
      t.text :auth, null: false

      t.timestamps
    end

    add_index :guest_push_subscriptions,
              [:conversation_id, :endpoint],
              unique: true,
              name: 'idx_guest_push_conversation_endpoint'
  end
end