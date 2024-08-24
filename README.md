# Rails Wallet App

## Overview
The Rails Wallet App is a Ruby on Rails application designed to manage wallets for users, teams, and stocks. The application provides functionality for creating and managing wallets, handling transactions (such as deposits, withdrawals, and transfers), and integrating with an external stock price API. The app uses custom session management for user authentication without relying on external gems.

## Features
- User, Team, and Stock Management: Create and manage users, teams, and stocks with associated wallets.
- Wallet Management: Create, view, and manage wallets for each user, team, or stock.
- Transaction Handling: Perform deposits, withdrawals, and transfers between wallets with proper validation.
- Stock Price Integration: Fetch real-time stock prices using the Latest Stock Price API.
- Custom Session Management: Simple and secure sign-in and sign-out functionality without external authentication gems.

## Getting Started
### Prerequisites

1. Clone the Repository
```sh
git clone https://github.com/havus/rails_wallet_app.git
```

2. Install Dependencies
```sh
bundle install
```

3. Setup Database
```sh
rails db:create
rails db:migrate
rails db:seed # if you need this in development mode
```

4. Run the Application

```sh
rails server
```

## Running Tests

The application includes RSpec tests for both models and requests.
To run the tests, use:
```sh
bundle exec rspec
```

## API Endpoints
Postman Documentation
https://documenter.getpostman.com/view/8345754/2sAXjDdac3

- User Management:
  - **POST** /sign_in: Sign in a user.
  - **DELETE** /sign_out: Sign out the user.
  - **GET** /users: List all users.
  - **GET** /users/:id: Get a specific user.
  - **POST** /users: Create a new user.
  - **GET** /users/:id/wallet: Get the wallet and balance for a specific user.

- Team Management:
  - **GET** /teams: List all teams.
  - **GET** /teams/:id: Get a specific team.
  - **POST** /teams: Create a new team.
  - **GET** /teams/:id/wallet: Get the wallet and balance for a specific team.

- Stock Management:
  - **GET** /stocks: List all stocks.
  - **GET** /stocks/:id: Get a specific stock.
  - **POST** /stocks: Create a new stock.
  - **GET** /stocks/:id/wallet: Get the wallet and balance for a specific stock.

- Transaction Management:
  - **POST** /api/v1/wallets/deposit: Deposit funds into a wallet.
  - **POST** /api/v1/wallets/withdraw: Withdraw funds from a wallet.
  - **POST** /api/v1/wallets/transfer: Transfer funds between wallets.

## Using the Latest Stock Price API
To fetch real-time stock prices:

Obtain an API Key: Sign up on RapidAPI and obtain your API key.
Configure the Client: Use the provided client in lib/latest_stock_price to interact with the API.

Third party: https://rapidapi.com/suneetk92/api/latest-stock-price

Example:
```ruby
client = LatestStockPrice::Client.new('your-apikey')
client.price('NIFTY 50')

Get prices for multiple stock symbols
client.prices(['NIFTY 50', 'BAJFINANCEEQN', 'HDFCBANKEQN'])

Get prices for all available stocks
client.price_all
```

## Contributing
Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch.
3. Make your changes and commit them.
4. Push to your branch and create a Pull Request.

## Contact
For any inquiries, please contact the repository owner through GitHub.
