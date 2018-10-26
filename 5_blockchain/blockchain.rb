require_relative "serializable"

class BlockChain
  include Serializable
  attr_reader :blocks
  attr_accessor :target

  def initialize(wallet, initial_target=2, start_amount=10_000_000)
    @target = initial_target
    @blocks = []
    @blocks << Block.create_genesis_block(wallet.genesis_trx(start_amount), initial_target)
  end

  def height
    @blocks.length
  end

  def add_to_chain(trx)
    block = Block.new(@blocks.last, trx, @target)
    raise ArgumentError, "Invalid trx" unless all_spends_valid?(@blocks.dup << block)
    @blocks << block
    puts block.to_s
    block
  end

  def valid?
    @blocks.all? { |block| block.is_a?(Block) } &&
      @blocks.all?(&:valid?) &&
      @blocks.each_cons(2).all? { |a, b| a.own_hash == b.prev_block_hash } &&
      all_spends_valid?(@blocks.dup)
  end

  def all_spends_valid?(blocks)
    compute_balances(blocks) do |balances, from, to|
      return false if balances.values_at(from, to).any? { |bal| bal < 0 }
    end
    true
  end

  def compute_balances(blocks)
    genesis_trx = blocks.first.trx
    balances = { genesis_trx.to => genesis_trx.amount }
    balances.default = 0 # New people automatically have balance of 0
    blocks.drop(1).each do |block| # Ignore the genesis block
      from = block.trx.from
      to = block.trx.to
      amount = block.trx.amount

      balances[from] -= amount
      balances[to] += amount
      yield balances, from, to if block_given?
    end
    balances
  end

  def to_s
    @blocks.map(&:to_s).join("\n")
  end
end
