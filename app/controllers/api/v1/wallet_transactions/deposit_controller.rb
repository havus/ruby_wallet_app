# frozen_string_literal: true

module Api
  module V1
    module WalletTransactions
      class DepositController < ApplicationController
        skip_before_action :verify_authenticity_token

        def create
          service = WalletServices::Deposit.new
          if service.perform(deposit_params)
            render(
              json: {
                message: 'Deposit successful',
                transaction_group: service.transaction_group,
              },
              status: :created,
            )
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        private

        def deposit_params
          params.require(:deposit).permit(:wallet_id, :amount, :note)
        end
      end
    end
  end
end
