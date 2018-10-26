require "virtus"
require "base64"
require_relative "crypto"

class Transaction
  include Virtus.model
  attribute :to, String
  attribute :from, String
  attribute :amount, Integer
  attribute :signature, String

  def sign!(privkey)
    self.signature = Crypto.sign(hash, privkey)
  end

  def genesis_trx?
    from.nil?
  end

  def valid?
    return true if genesis_trx?
    Crypto.valid_signature?(hash, signature, decode(:from))
  end

  def hash
    Crypto.hash([from, to, amount].compact.join)
  end

  private

  def decode(attr)
    Base64.decode64(self[attr])
  end
end
