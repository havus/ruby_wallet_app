# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::WalletTransactions::Deposit', type: :request do
  describe 'POST /api/v1/wallet_transactions/deposit' do
    let_it_be(:wallet) { create(:wallet) }

    context 'with valid parameters' do
      let(:params) do
        {
          deposit: {
            wallet_id: wallet.id,
            amount: 100.00,
            note: 'Deposit for testing'
          }
        }
      end

      it 'creates a new deposit transaction' do
        post '/api/v1/wallet_transactions/deposit', params: params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Deposit successful')
        expect(TransactionGroup.count).to eq(1)
        expect(TransactionEntry.count).to eq(1)
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          deposit: {
            wallet_id: 0,
            amount: 100.00,
            note: 'Invalid deposit'
          }
        }
      end

      it 'does not create a new deposit transaction and returns errors' do
        post '/api/v1/wallet_transactions/deposit', params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Wallet not found')
        expect(TransactionGroup.count).to eq(0)
        expect(TransactionEntry.count).to eq(0)
      end
    end
  end
end
