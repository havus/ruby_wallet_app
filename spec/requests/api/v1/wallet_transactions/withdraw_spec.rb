# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::WalletTransactions::Withdraw', type: :request do
  describe 'POST /api/v1/wallet_transactions/withdraw' do
    let_it_be(:wallet) { create(:wallet) }

    context 'with valid parameters' do
      let(:params) do
        {
          withdraw: {
            wallet_id: wallet.id,
            amount: 50.00,
            note: 'Withdraw for testing',
          },
        }
      end

      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(wallet).and_return(100.00)
      end

      it 'creates a new withdraw transaction' do
        post '/api/v1/wallet_transactions/withdraw', params: params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Withdraw successful')
        expect(TransactionGroup.count).to eq(1)
        expect(TransactionEntry.count).to eq(1)
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          withdraw: {
            wallet_id: 0,
            amount: 50.00,
            note: 'Invalid withdraw',
          },
        }
      end

      it 'does not create a new withdraw transaction and returns errors' do
        post '/api/v1/wallet_transactions/withdraw', params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Wallet not found')
        expect(TransactionGroup.count).to eq(0)
        expect(TransactionEntry.count).to eq(0)
      end
    end
  end
end
