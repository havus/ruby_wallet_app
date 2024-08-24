# frozen_string_literal: true

require 'faraday'
require 'json'

# client = LatestStockPrice::Client.new('4301f013a0mshf3a24894b4c9b32p14c0efjsna502b8ab8bf6')
# client.price('NIFTY 50')

# Get prices for multiple stock symbols
# client.prices(['NIFTY 50', 'BAJFINANCEEQN', 'HDFCBANKEQN'])

# Get prices for all available stocks
# client.price_all

module LatestStockPrice
  class Client
    BASE_URL = 'https://latest-stock-price.p.rapidapi.com'

    def initialize(api_key)
      @api_key = api_key
      @connection = Faraday.new(url: BASE_URL) do |faraday|
        faraday.headers['X-RapidAPI-Key'] = @api_key
        faraday.headers['X-RapidAPI-Host'] = 'latest-stock-price.p.rapidapi.com'
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.response :logger, ::Logger.new(STDOUT)
      end
    end

    def price(stock_symbol)
      response = @connection.get('/any', { Identifier: stock_symbol })

      parse_response(response)
    end

    def prices(stock_symbols)
      symbols = stock_symbols.join(',')
      response = @connection.get('/any', { Identifier: symbols })

      parse_response(response)
    end

    def price_all
      response = @connection.get('/any')

      parse_response(response)
    end

    private

    def parse_response(response)
      if response.success?
        JSON.parse(response.body)
      else
        {
          status: response.status,
          body: response.body,
        }
      end
    rescue JSON::ParserError => e
      {
        error: 'JSON Parsing Error',
        message: e.message,
      }
    end
  end
end
