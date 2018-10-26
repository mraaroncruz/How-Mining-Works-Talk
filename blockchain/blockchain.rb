class BlockChain
  attr_reader :blocks
  attr_accessor :target

  def initialize(wallet, initial_target=2, start_amount=10_000_000)
    @target = initial_target
    @blocks = []
    @blocks << Block.create_genesis_block(wallet.genesis_trx(start_amount), initial_target)
  end

  def length
    @blocks.length
  end

  def add_to_chain(trx)
    @blocks << Block.new(@blocks.last, trx, @target)
  end

  def valid?
    @blocks.all? { |block| block.is_a?(Block) } &&
      @blocks.all?(&:valid?) &&
      @blocks.each_cons(2).all? { |a, b| a.own_hash == b.prev_block_hash } &&
      all_spends_valid?
  end

  def all_spends_valid?
    compute_balances do |balances, from, to|
      return false if balances.values_at(from, to).any? { |bal| bal < 0 }
    end
    true
  end

  def compute_balances
    genesis_trx = @blocks.first.trx
    balances = { genesis_trx.to => genesis_trx.amount }
    balances.default = 0 # New people automatically have balance of 0
    @blocks.drop(1).each do |block| # Ignore the genesis block
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
