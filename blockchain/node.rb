require "bundler/setup"
Bundler.require
require_relative "helpers"
extend Helpers

$hostname = ENV.fetch("HOSTNAME")
peers = ENV.fetch("SEED") { "" }.split(",").reject { |peer| peer == $hostname }
$peers = Concurrent::Array.new(peers)
$transaction_pool = Concurrent::Array.new

every 3 do
  $peers.dup.each do |peer|
    gossip(peer)
  end
end

class Node < Sinatra::Base
  helpers Helpers

  configure do
    puts "My hostname is " + $hostname.green
  end

  get "/block_height" do
    $blockchain.height
  end

  get "/transaction" do
    Marshal.dump($transaction_pool.first)
  end

  post "/gossip" do
    peer_blockchain = Marshal.load(params[:blockchain])
    peer_peers = Marshal.load(params[:peers])
    update_blockchain(peer_blockchain)
    update_peers(peer_peers)
    Marshal.dump($blockchain)
  end
end
