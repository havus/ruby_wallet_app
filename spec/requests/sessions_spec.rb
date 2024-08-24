# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let_it_be(:user) { create(:user, email: 'user@example.com', password: 'password123') }

  describe 'POST /sign_in' do
    context 'with valid credentials' do
      it 'signs in the user and sets the session' do
        post '/sign_in', params: { email: 'user@example.com', password: 'password123' }

        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq('Signed in successfully')
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context 'with invalid credentials' do
      it 'does not sign in the user and returns an error' do
        post '/sign_in', params: { email: 'user@example.com', password: 'wrongpassword' }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['errors']).to eq('Invalid email or password')
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe 'DELETE /sign_out' do
    before do
      # sign in the user first
      post '/sign_in', params: { email: 'user@example.com', password: 'password123' }
    end

    it 'signs out the user and clears the session' do
      # assert before sign out
      expect(session[:user_id]).to_not be_nil

      delete '/sign_out'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Signed out successfully')
      expect(session[:user_id]).to be_nil
    end
  end
end
