require "faraday"
class Client
  class << self
    def send(trx)
      Faraday.post("http://localhost:3000/send_money", trx.to_h).body
    end
  end
end
