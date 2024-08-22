# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Stocks', type: :request do
  let_it_be(:stocks) { create_list(:stock, 5) }
  let(:stock_id) { stocks.first.id }

  describe 'GET /api/v1/stocks' do
    it 'returns all stocks' do
      get '/api/v1/stocks'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe 'GET /api/v1/stocks/:id' do
    context 'when the stock exists' do
      it 'returns the stock' do
        get "/api/v1/stocks/#{stock_id}"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(stock_id)
      end
    end

    context 'when the stock does not exist' do
      it 'returns a not found error' do
        get '/api/v1/stocks/9999'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq('Stock not found')
      end
    end
  end

  describe 'POST /api/v1/stocks' do
    context 'with valid parameters' do
      let(:params) do
        { stock: { name: 'Stock A' } }
      end

      it 'creates a new stock' do
        expect {
          post '/api/v1/stocks', params: params
        }.to change { Stock.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Stock created successfully')
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        { stock: { name: '' } }
      end

      it 'does not create a new stock and returns errors' do
        expect {
          post '/api/v1/stocks', params: params
        }.to change { Stock.count }.by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'GET /api/v1/stocks/:id/wallet' do
    let_it_be(:stock) { create(:stock) }
    let(:wallet) { create(:wallet, owner: stock) }

    context 'when the stock has a wallet' do
      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(wallet).and_return(true)
        allow_any_instance_of(WalletServices::GetBalance).to receive(:result).and_return(300.00)
      end

      it 'returns the wallet and balance' do
        get "/api/v1/stocks/#{stock.id}/wallet"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['wallet']['id']).to eq(wallet.id)
        expect(JSON.parse(response.body)['balance']).to eq(300.00)
      end
    end

    context 'when the stock does not have a wallet' do
      it 'returns a wallet not found error' do
        get "/api/v1/stocks/#{stock.id}/wallet"

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq('Wallet not found')
      end
    end
  end
end
