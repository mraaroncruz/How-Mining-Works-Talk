require "colorize"
require "digest"
require_relative "crypto"
require_relative "transaction"

class Block
  attr_reader :own_hash, :prev_block_hash, :trx, :target

  def self.create_genesis_block(genesis_trx, initial_target=1)
    Block.new(nil, genesis_trx, initial_target)
  end

  def initialize(prev_block, trx, target)
    raise TypeError unless trx.is_a?(Transaction)
    @target = target
    @trx = trx
    @prev_block_hash = prev_block.own_hash if prev_block
    mine_block!
  end

  def mine_block!
    @nonce = calc_nonce
    @own_hash = hash(full_block(@nonce))
  end

  def valid?
    is_valid_nonce?(@nonce) && @trx.valid?
  end

  def to_s
    [
      "Previous hash: ".rjust(15) + @prev_block_hash.to_s.yellow,
      "Message: ".rjust(15) + @trx.to_s.green,
      "Nonce: ".rjust(15) + @nonce.light_blue,
      "Own hash: ".rjust(15) + @own_hash.yellow,
      "↓".rjust(40),
    ].join("\n")
  end

  private

  def hash(contents)
    Crypto.hash(contents)
  end

  def calc_nonce
    nonce = "PIVORAK 2018 ROCKS!!!!!"
    count = 0
    until is_valid_nonce?(nonce)
      print "." if count % 100_000 == 0
      nonce = nonce.next
      count += 1
    end
    nonce
  end

  def is_valid_nonce?(nonce)
    hash(full_block(nonce)).start_with?("0" * target)
  end

  def full_block(nonce)
    [@trx.hash, @prev_block_hash, nonce].compact.join
  end
end
