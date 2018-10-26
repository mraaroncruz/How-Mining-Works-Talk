require "faraday"
class Client
  class << self
    def gossip(peer, data)
      url = "http://#{peer}:3000/gossip"
      Faraday.post(url, data: data).body
    end

    def raise_target(peer, target)
      Faraday.post("http://#{peer}:3000/target", target: target)
    rescue => e
      nil
    end
  end
end
