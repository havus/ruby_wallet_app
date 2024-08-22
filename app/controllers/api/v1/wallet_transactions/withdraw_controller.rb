# frozen_string_literal: true

module Api
  module V1
    module WalletTransactions
      class WithdrawController < ApplicationController
        skip_before_action :verify_authenticity_token

        def create
          service = WalletServices::Withdraw.new
          if service.perform(withdraw_params)
            render(
              json: {
                message: 'Withdraw successful',
                transaction_group: service.transaction_group,
              },
              status: :created,
            )
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        private

        def withdraw_params
          params.require(:withdraw).permit(:wallet_id, :amount, :note)
        end
      end
    end
  end
end
