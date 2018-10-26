class Tweeter
  def initialize(term)
    Thread.abort_on_exception = true
    @term = term
    @client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV.fetch "CONSUMER_KEY"
      config.consumer_secret     = ENV.fetch "CONSUMER_SECRET"
      config.access_token        = ENV.fetch "ACCESS_TOKEN"
      config.access_token_secret = ENV.fetch "ACCESS_SECRET"
    end
  end

  def start
    Thread.new do
      @client.filter(track: @term) do |object|
        puts "Found tweet!".green
        $tweets.push object.text if object.is_a?(Twitter::Tweet)
      end
    end
  end
end
