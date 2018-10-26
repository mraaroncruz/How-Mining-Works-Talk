require "faraday"
class Client
  class << self
    def gossip(peer, peers, blockchain)
      data = blockchain.nil? ?
        {} :
        { blockchain: blockchain, peers: peers }
      body = Faraday.post("http://#{peer}:3000/gossip", data).body
      Marshal.load(body)
    end

    def raise_target(peer, target)
      Faraday.post("http://#{peer}:3000/target", target: target)
    rescue => e
      nil
    end
  end
end
