require "base64"
require_relative "transaction"
require_relative "crypto"

class Wallet
  attr_reader :pub_key, :priv_key
  def initialize(priv_key = nil, pub_key = nil)
    if priv_key.nil?
      @priv_key, @pub_key = Crypto.generate_key_pair
    else
      @priv_key = priv_key
      @pub_key = pub_key
    end
  end

  def address
    Base64.encode64(pub_key)
  end

  def first_trx(amount)
    trx = Transaction.new(from: nil, to: address, amount: amount)
    sign_trx(trx)
  end

  def sign_trx(trx)
    trx.sign!(priv_key)
    trx
  end

  def send(to_address, amount)
    trx = Transaction.new(to: to_address, from: address, amount: amount)
    sign_trx(trx)
  end
end
