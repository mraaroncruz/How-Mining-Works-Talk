require "bundler/setup"
Bundler.require
require_relative "helpers"
require_relative "tweeter"

extend Helpers


every 3 do
  gossip
end

every 10 do
  print_tweets
end

class Node < Sinatra::Base
  helpers Helpers

  configure do
    Dotenv.load
    # Set up Globals
    $tweets = Concurrent::Array.new
    $hostname = ENV.fetch("HOSTNAME")
    peers = ENV.fetch("SEED") { "" }.split(",").reject { |peer| peer == $hostname }
    $peers = Concurrent::Array.new(peers)
    if $hostname == "master"
      term = ENV.fetch("TERM") { "trump" }
      Tweeter.new(term).start
    end
  end

  post "/peers" do
    peer = params[:peer]
    update_peers(peer)
    $peers.inspect
  end
  get "/peers" do
    $peers.inspect
  end

  post "/gossip" do
    data = Marshal.load(params[:data])
    update_tweets(data[:tweets])
    update_peers(data[:peers])
    # Response
    dump_state
  end

  post "/target" do
    new_target = params[:target].to_i
    $blockchain.target = new_target
    new_target.to_s
  end
end
