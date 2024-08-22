# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Teams', type: :request do
  let_it_be(:teams) { create_list(:team, 5) }
  let(:team_id) { teams.first.id }

  describe 'GET /api/v1/teams' do
    it 'returns all teams' do
      get '/api/v1/teams'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe 'GET /api/v1/teams/:id' do
    context 'when the team exists' do
      it 'returns the team' do
        get "/api/v1/teams/#{team_id}"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(team_id)
      end
    end

    context 'when the team does not exist' do
      it 'returns a not found error' do
        get '/api/v1/teams/9999'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq('Team not found')
      end
    end
  end

  describe 'POST /api/v1/teams' do
    context 'with valid parameters' do
      let(:params) do
        {
          team: {
            name: 'Team Alpha',
            email: 'teamalpha@example.com',
            password: 'password123',
          },
        }
      end

      it 'creates a new team' do
        expect {
          post '/api/v1/teams', params: params
        }.to change { Team.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Team created successfully')
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          team: {
            name: '',
            email: '',
            password: '',
          },
        }
      end

      it 'does not create a new team and returns errors' do
        expect {
          post '/api/v1/teams', params: params
        }.to change { Team.count }.by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include(
          "Name can't be blank", "Email can't be blank", "Password hash can't be blank",
        )
      end
    end
  end

  describe 'GET /api/v1/teams/:id/wallet' do
    let_it_be(:team) { create(:team) }
    let(:wallet) { create(:wallet, owner: team) }

    context 'when the team has a wallet' do
      before do
        allow_any_instance_of(WalletServices::GetBalance).to receive(:perform).with(wallet).and_return(true)
        allow_any_instance_of(WalletServices::GetBalance).to receive(:result).and_return(200.00)
      end

      it 'returns the wallet and balance' do
        get "/api/v1/teams/#{team.id}/wallet"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['wallet']['id']).to eq(wallet.id)
        expect(JSON.parse(response.body)['balance']).to eq(200.00)
      end
    end

    context 'when the team does not have a wallet' do
      it 'returns a wallet not found error' do
        get "/api/v1/teams/#{team.id}/wallet"

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq('Wallet not found')
      end
    end
  end
end
