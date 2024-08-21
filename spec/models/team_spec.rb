# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  include_context :walletable

  describe 'attributes' do
    it { is_expected.to respond_to(:password_hash) }
    it { is_expected.to respond_to(:email) }
  end
end
