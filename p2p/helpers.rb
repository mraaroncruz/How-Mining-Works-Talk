require "faraday"
require "securerandom"

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

  def fetch_state_from_peers(peers, my_host)
    new_peers = make_statemap(peers)
    peers.each do |peer|
      host = peer["hostname"]
      next if host == my_host
      begin
        res = client.get("http://#{host}:3000")
        update_from_res(res, new_peers) if res.success?
      rescue => e
        puts "Couldn't connect to node #{host}, removing peer: ".green + e.message.red
      end
    end
    new_peers.values
  end

  def update_from_res(res, new_peers)
    if res.success?
      Array(JSON.load(res.body)).each do |remote_peer|
        r_host = remote_peer["hostname"]
        if new_peers[r_host].nil? || remote_peer["version"] > new_peers[r_host]["version"]
          new_peers[r_host] = remote_peer
        end
      end
    end
  end

  def make_statemap(peers)
    peers.each_with_object({}) { |p, h| h[p["hostname"]] = p }
  end

  def update_peer(my_state, peer_state)
    new_peers = make_statemap(my_state)
    peer_state.each do |remote_peer|
      r_host = remote_peer["hostname"]
      if new_peers[r_host].nil? || remote_peer["version"] > new_peers[r_host]["version"]
        new_peers[r_host] = remote_peer
      end
    end
    new_peers.values
  end

  def update_my_state(peers, hostname)
    i = peers.index { |p| p["hostname"] == hostname }
    if i.nil?
      peers.push({
        "version" => 0,
        "random" => "0+" + SecureRandom.hex,
        "hostname" => hostname
      })
    else
      peers[i]["version"]
      peers[i]["version"] += 1
      peers[i]["random"] = peers[i]["version"].to_s + "+" + SecureRandom.hex
    end
  end

  def join_network(peers, host)
    new_peers = make_statemap(peers)
    peers.each do |peer|
      next if peer["hostname"] == host
      begin
        res = client.post("http://#{peer['hostname']}:3000/join", { hostname: host, state: peers }.to_json)
        update_from_res(res, new_peers)
      rescue => e
        puts "Couldn't connect to node #{peer['hostname']}, removing peer: ".green + e.message.red
      end
    end
    new_peers.values
  end

  def print_state(peers)
    peers.each do |peer|
      puts [
        "Host: ".rjust(15) + peer["hostname"].to_s.yellow,
        "Version: ".rjust(15) + peer["version"].to_s.green,
        "State: ".rjust(15) + peer["random"].to_s.red,
        "↓".rjust(40),
      ].join("\n")
    end
    puts "-" * 50
  end

  def client
    @client ||= Faraday.new do |cli|
      cli.headers["Content-Type"] = "application/json"
      cli.headers["Accept"] = "application/json"
      cli.adapter Faraday.default_adapter
    end
  end
end
