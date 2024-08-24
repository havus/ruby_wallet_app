# frozen_string_literal: true

require 'rails_helper'

# require 'latest_stock_price/client'

RSpec.describe LatestStockPrice::Client do
  let(:api_key) { 'test_api_key' }
  let(:client) { described_class.new(api_key) }
  let(:all_mocked_responses) do
    read_file_fixture('rapidapi/latest_stock_price/price_all.json')
  end

  let(:base_url) { 'https://latest-stock-price.p.rapidapi.com' }
  let(:default_header) do
    {
      'X-RapidAPI-Key' => api_key,
      'X-RapidAPI-Host' => 'latest-stock-price.p.rapidapi.com',
    }
  end

  describe '#price' do
    let(:identifier) { 'NIFTY 50' }

    context 'when the response is successful' do
      let(:mocked_response) do
        all_mocked_responses.select { |res| res['identifier'] == identifier }
      end

      before do
        stub_request(:get, "#{base_url}/any")
          .with(
            headers: default_header,
            query: { Identifier: identifier },
          )
          .to_return(status: 200, body: mocked_response.to_json)
      end

      it 'returns the parsed response' do
        response = client.price(identifier)

        expect(response).to eq mocked_response
      end
    end

    context 'when the response is not successful' do
      let(:error_response) do
        {
          'message': 'Invalid API key. Go to https://docs.rapidapi.com/docs/keys for more info.',
        }.as_json
      end

      before do
        stub_request(:get, "#{base_url}/any")
          .with(
            headers: default_header,
            query: { Identifier: identifier },
          )
          .to_return(status: 401, body: error_response.to_json)
      end

      it 'returns the error status and body' do
        expected_response = { status: 401, body: error_response.to_json }
        response = client.price(identifier)

        expect(response).to eq expected_response
      end
    end

    context 'when the response contains invalid JSON' do
      before do
        stub_request(:get, "#{base_url}/any")
          .with(
            headers: default_header,
            query: { Identifier: identifier },
          )
          .to_return(status: 200, body: 'Invalid JSON')
      end

      it 'returns a JSON parsing error' do
        expected_response = {
          error: 'JSON Parsing Error',
          message: "unexpected token at 'Invalid JSON'",
        }
        response = client.price(identifier)

        expect(response).to eq expected_response
      end
    end
  end

  describe '#prices' do
    context 'when the response is successful' do
      let(:identifiers) { ['NIFTY 50', 'BAJFINANCEEQN', 'HDFCBANKEQN'] }
      let(:mocked_response) do
        all_mocked_responses.select { |res| identifiers.include?(res['identifier']) }
      end

      before do
        stub_request(:get, "#{base_url}/any")
          .with(
            headers: default_header,
            query: { Identifier: identifiers.join(',') },
          )
          .to_return(status: 200, body: mocked_response.to_json)
      end

      it 'returns the parsed response' do
        response = client.prices(identifiers)
        expect(response).to eq mocked_response
      end
    end
  end

  describe '#price_all' do
    context 'when the response is successful' do
      before do
        stub_request(:get, "#{base_url}/any")
          .with(headers: default_header)
          .to_return(status: 200, body: all_mocked_responses.to_json)
      end

      it 'returns the parsed response' do
        response = client.price_all
        expect(response).to eq all_mocked_responses
      end
    end
  end
end
