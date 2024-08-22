# frozen_string_literal: true

module Api
  module V1
    class StocksController < ApplicationController
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

      private

      def stock_params
        params.require(:stock).permit(:name)
      end
    end
  end
end
