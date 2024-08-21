# frozen_string_literal: true

RSpec.shared_examples :walletable do
  describe 'associations' do
    it { is_expected.to have_one(:wallet).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
