# frozen_string_literal: true

module Api
  module V1
    module WalletTransactions
      class TransferController < ApplicationController
        def create
          service = WalletServices::Transfer.new
          if service.perform(transfer_params)
            render(
              json: {
                message: 'Transfer successful',
                transaction_group: service.transaction_group,
              },
              status: :created,
            )
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        private

        def transfer_params
          params.require(:transfer).permit(:source_wallet_id, :target_wallet_id, :amount, :note)
        end
      end
    end
  end
end
