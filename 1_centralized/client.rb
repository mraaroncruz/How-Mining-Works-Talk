require "faraday"
class Client
  class << self
    def send(from, to, amount)
      Faraday.post("http://localhost:3000/send_money", to: to, from: from, amount: amount).body
    end
  end
end
