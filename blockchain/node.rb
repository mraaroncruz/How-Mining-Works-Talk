require "bundler/setup"
Bundler.require
require_relative "helpers"
require_relative "types"
extend Helpers

# Set up Globals
$hostname = ENV.fetch("HOSTNAME")
peers = ENV.fetch("SEED") { "" }.split(",").reject { |peer| peer == $hostname }
$peers = Concurrent::Array.new(peers)
$transaction_pool = Concurrent::Array.new
$graylist = []

if $hostname == "master"
  $wallet = Wallet.new
  $blockchain = BlockChain.new($wallet)
  # For demo convenience
  puts "Wallet pubic key is #{$wallet.pub_key}".blue
  File.write("/keys/key.pub", $wallet.pub_key)
  puts "Wallet private key is #{$wallet.priv_key}".green
  File.write("/keys/key", $wallet.priv_key)
end

every 3 do
  gossip
end

every 10 do
  print_blockchain
end

class Node < Sinatra::Base
  helpers Helpers

  configure do
    puts "My hostname is " + $hostname.green
  end

  get "/block_height" do
    $blockchain.height
  end

  post "/transaction" do
    trx_dump = params[:transaction]
    trx = Transaction.load(trx_dump)
    block = $blockchain.add_to_chain(trx)
    s = block.to_s
    puts "\n== Block Mined =="
    puts s
    s
  end

  post "/peers" do
    peer = params[:peer]
    $graylist = $graylist - [peer]
    update_peers(peer)
    $peers.inspect
  end
  get "/peers" do
    $peers.inspect
  end

  post "/gossip" do
    # If params don't have a blockchain,
    # request is coming from a fresh node and just wants data
    unless params[:blockchain].nil?
      peer_blockchain = BlockChain.load(params[:blockchain])
      peer_peers = Marshal.load(params[:peers])
      # Make sure host is not on the graylist anymore if they reconnect
      $graylist = $graylist - peer_peers.reverse.take(1)
      update_blockchain(peer_blockchain)
      update_peers(peer_peers)
    end
    # Response
    Marshal.dump({
      blockchain: $blockchain.dump,
      peers: Marshal.dump($peers)
    })
  end

  post "/target" do
    new_target = params[:target].to_i
    $blockchain.target = new_target
    new_target.to_s
  end
end
