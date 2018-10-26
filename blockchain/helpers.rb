require_relative "client"
require "faraday"
Thread.abort_on_exception = true

module Helpers
  def every(seconds)
    Thread.new do
      loop do
        sleep seconds
        yield
      end
    end
  end

  def update_blockchain(blockchain)
    return $blockchain = blockchain if $blockchain.nil?
    return unless blockchain.valid?
    return unless blockchain.height > $blockchain.height
    $blockchain = blockchain
  end

  def update_peers(peers)
    $peers = ($peers + Array(peers)).uniq
  end

  def gossip
    $peers.dup
      .reject { |peer| $graylist.include?(peer) }
      .each do |peer|
        gossip_with_peer(peer)
      end
  end

  def print_blockchain
    puts $blockchain.to_s
    puts ("-" * 50).blue
    puts ""
  end

  private

  def gossip_with_peer(peer)
    bc = $blockchain.nil? ? nil : $blockchain.dump
    gossip_response = Client.gossip(peer, Marshal.dump($peers + [$hostname]), bc)
    their_peers = Marshal.load(gossip_response[:peers])
    their_blockchain = BlockChain.load(gossip_response[:blockchain])
    update_peers(their_peers)
    update_blockchain(their_blockchain)
  rescue Faraday::ConnectionFailed => e
    puts e.message.red
    puts "Forgetting #{peer}".green
    $graylist = $graylist.push(peer).uniq
    $peers = $peers - [peer]
  end
end
