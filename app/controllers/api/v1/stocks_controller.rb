# frozen_string_literal: true

module Api
  module V1
    class StocksController < ApplicationController
      skip_before_action :verify_authenticity_token

      def index
        stocks = Stock.all
        render json: stocks, status: :ok
      end

      def show
        stock = Stock.find(params[:id])
        render json: stock, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'Stock not found' }, status: :not_found
      end

      def create
        stock = Stock.new(stock_params)
        if stock.save
          render json: { message: 'Stock created successfully', stock: stock }, status: :created
        else
          render json: { errors: stock.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def wallet
        stock = Stock.find(params[:id])
        wallet = stock.wallet

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

      def stock_params
        params.require(:stock).permit(:name)
      end
    end
  end
end
