require "base64"
require_relative "transaction"
require_relative "crypto"

class Wallet
  attr_reader :pub_key, :priv_key
  def initialize
    @priv_key, @pub_key = Crypto.generate_key_pair
  end

  def address
    Base64.encode64(pub_key)
  end

  def genesis_trx(amount)
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
