class GuestPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find_by(id: message_id)

    return unless message
    return unless message.message_type_before_type_cast == 1
    return if message.private?

    subscriptions = GuestPushSubscription.where(
      conversation_id: message.conversation_id
    )

    return if subscriptions.empty?

    subscriptions.find_each do |subscription|
      send_push(subscription, message)
    end
  end

  private

  def send_push(subscription, message)
    payload = {
      title: 'Pesan baru dari Cicana',
      body: message.content.to_s,
      icon: 'https://cicana.co/wp-content/uploads/2024/04/LOGO-CICANA.png',
      tag: "cicana-message-#{message.id}",
      url: 'https://cicana.co/'
    }

    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      vapid: {
        subject: ENV.fetch('VAPID_SUBJECT'),
        public_key: ENV.fetch('VAPID_PUBLIC_KEY'),
        private_key: ENV.fetch('VAPID_PRIVATE_KEY')
      }
    )

    Rails.logger.info(
      "[Guest Push] Push berhasil dikirim " \
      "conversation=#{message.conversation_id} " \
      "subscription=#{subscription.id}"
    )
  rescue StandardError => e
    Rails.logger.error(
      "[Guest Push] Gagal mengirim push " \
      "conversation=#{message.conversation_id} " \
      "subscription=#{subscription.id} " \
      "error=#{e.class}: #{e.message}"
    )
  end
end