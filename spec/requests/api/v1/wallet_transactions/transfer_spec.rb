# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::WalletTransactions::Transfer', type: :request do
  describe 'POST /api/v1/wallet_transactions/transfer' do
    let_it_be(:source_wallet) { create(:wallet) }
    let_it_be(:target_wallet) { create(:wallet) }

    context 'with valid parameters' do
      let(:params) do
        {
          transfer: {
            source_wallet_id: source_wallet.id,
            target_wallet_id: target_wallet.id,
            amount: 50.00,
            note: 'Transfer for testing'
          }
        }
      end

      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(source_wallet).and_return(100.00)
      end

      it 'creates a new transfer transaction' do
        post '/api/v1/wallet_transactions/transfer', params: params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Transfer successful')
        expect(TransactionGroup.count).to eq(1)
        expect(TransactionEntry.count).to eq(2)
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          transfer: {
            source_wallet_id: 0,
            target_wallet_id: target_wallet.id,
            amount: 50.00,
            note: 'Invalid transfer'
          }
        }
      end

      it 'does not create a new transfer transaction and returns errors' do
        post '/api/v1/wallet_transactions/transfer', params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Wallet with ID 0 not found')
        expect(TransactionGroup.count).to eq(0)
        expect(TransactionEntry.count).to eq(0)
      end
    end
  end
end
