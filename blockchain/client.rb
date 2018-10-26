require "faraday"
class Client
  def gossip(peer)
    res = Faraday.post("http://#{peer}:3000/gossip",
      blockchain: Marshal.dump($blockchain),
      peers: Marshal.dump($peers
    )
  rescue Faraday::ConnectionError
    $peers.delete(peer)
  end
end