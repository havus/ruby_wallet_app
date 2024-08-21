# frozen_string_literal: true

module Walletable
  extend ActiveSupport::Concern

  included do
    has_one :wallet, as: :owner, dependent: :destroy

    validates :name, presence: true
  end

  class_methods do
  end
end
