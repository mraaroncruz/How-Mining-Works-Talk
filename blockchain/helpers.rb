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
end
