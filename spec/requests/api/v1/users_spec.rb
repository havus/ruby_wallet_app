# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let_it_be(:users) { create_list(:user, 5) }
  let(:user_id) { users.first.id }

  describe 'GET /api/v1/users' do
    it 'returns all users' do
      get '/api/v1/users'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe 'GET /api/v1/users/:id' do
    context 'when the user exists' do
      it 'returns the user' do
        get "/api/v1/users/#{user_id}"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(user_id)
      end
    end

    context 'when the user does not exist' do
      it 'returns a not found error' do
        get '/api/v1/users/0'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to eq('User not found')
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'with valid parameters' do
      let(:params) do
        {
          user: {
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
          },
        }
      end

      it 'creates a new user' do
        expect {
          post '/api/v1/users', params: params
        }.to change { User.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('User created successfully')
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          user: {
            name: '',
            email: '',
            password: '',
          },
        }
      end

      it 'does not create a new user and returns errors' do
        expect {
          post '/api/v1/users', params: params
        }.to change { User.count }.by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include(
          "Name can't be blank", "Email can't be blank", "Password hash can't be blank",
        )
      end
    end
  end
end
