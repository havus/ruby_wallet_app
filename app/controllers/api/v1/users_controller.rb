# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token

      def index
        users = User.all
        render json: users, status: :ok
      end

      def show
        user = User.find(params[:id])
        render json: user, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'User not found' }, status: :not_found
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: { message: 'User created successfully', user: user }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def wallet
        user = User.find(params[:id])
        wallet = user.wallet

        if wallet
          get_balance = WalletServices::GetBalance.new
          get_balance.perform(wallet)

          render(
            json: {
              wallet: wallet,
              balance: get_balance.result,
            },
            status: :ok,
          )
        else
          render json: { errors: 'Wallet not found' }, status: :not_found
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password)
      end
    end
  end
end
