require "bundler/setup"
Bundler.require
Dotenv.load
require "json"

require_relative "helpers"

class Server < Sinatra::Base
  extend Helpers

  configure do
    peers = ENV.fetch("SEED") { "" }.split(",").map { |host|
      { "hostname" => host, "version" => 0 }
    }
    set :peers, Concurrent::Array.new(peers)

    hostname = ENV.fetch("HOSTNAME")
    set :hostname, hostname
    puts "My hostname is " + hostname.green

    update_my_state(settings.peers, hostname)
    settings.peers = join_network(peers, hostname)

    every 5 do
      settings.peers = fetch_state_from_peers(settings.peers, hostname)
    end

    every 10 do
      update_my_state(settings.peers, hostname)
    end

    every 15 do
      print_state(settings.peers)
    end
  end

  before do
    content_type :json
    request.body.rewind
    b = request.body.read
    @params = JSON.load(b) if b
  end

  get "/" do
    settings.peers.to_json
  end

  # @param `hostname` - hostname of new node
  # @param `state` - state of node
  # @returns
  # `peers` - current state of this node, including known peers
  post "/join" do
    puts "#{settings.hostname} Received ".green + @params["state"].inspect.red
    peers = settings.peers
    settings.peers = self.class.update_peer(peers, @params["state"])
    puts "#{settings.hostname} Merged ".green + settings.peers.inspect.red
    settings.peers.to_json
  end
end
