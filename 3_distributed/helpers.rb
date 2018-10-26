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

  def update_tweets(tweets)
    if tweets && tweets.is_a?(Array) && tweets.size > $tweets.size
      $tweets = tweets
    end
  end

  def update_peers(peers)
    $peers = ($peers + Array(peers)).uniq
  end

  def gossip
    $peers.dup.each do |peer|
      gossip_with_peer(peer)
    end
  end

  def dump_state
    Marshal.dump({
      tweets: $tweets,
      peers: $peers
    })
  end

  def load_state(dump)
    Marshal.load(dump)
  end

  def print_tweets
    system "clear"
    puts "\n\n\n*** Your Tweets ***"
    $tweets.each do |tweet|
      puts tweet.yellow
      puts ""
    end
    puts "\n\n"
    puts "-" * 50
  end

  private

  def gossip_with_peer(peer)
    gossip_response = Client.gossip(peer, dump_state)
    data = load_state(gossip_response)
    their_peers = data[:peers]
    their_tweets = data[:tweets]
    update_peers(their_peers)
    update_tweets(their_tweets)
  rescue Faraday::ConnectionFailed => e
    $peers = $peers - [peer]
  end
end
