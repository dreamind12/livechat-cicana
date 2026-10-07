module Api
  module V1
    module Widget
      class GuestPushSubscriptionsController < ActionController::API
        def create
          conversation = Conversation.find(params[:conversation_id])

          endpoint = params[:endpoint]

          unless endpoint.present?
            return render json: {
              success: false,
              errors: ['Endpoint wajib diisi']
            }, status: :unprocessable_entity
          end

          # Satu PushSubscription endpoint hanya boleh terhubung
          # ke satu conversation pada account yang sama.
          #
          # Kalau browser/device yang sama pindah ke conversation
          # lain, hapus hubungan endpoint dengan conversation sebelumnya.
          GuestPushSubscription
            .where(
              account_id: conversation.account_id,
              endpoint: endpoint
            )
            .where.not(conversation_id: conversation.id)
            .delete_all

          subscription = GuestPushSubscription.find_or_initialize_by(
            conversation_id: conversation.id,
            endpoint: endpoint
          )

          subscription.account_id = conversation.account_id
          subscription.p256dh = params.dig(:keys, :p256dh)
          subscription.auth = params.dig(:keys, :auth)

          if subscription.save
            render json: {
              success: true,
              id: subscription.id,
              conversation_id: conversation.id
            }, status: :created
          else
            render json: {
              success: false,
              errors: subscription.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end