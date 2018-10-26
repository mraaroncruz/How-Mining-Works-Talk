require "digest"
require "colorize"

class POW
  attr_reader :target

  def initialize(target)
    @target = target
  end

  def find_nonce(message)
    nonce = "WHAT'S UP PIVORAK?!?!"
    count = 0
    until is_valid_nonce?(nonce, message)
      print "." if count % 100_000 == 0
      nonce = nonce.next
      count += 1
    end
    puts ""
    puts signature(message, nonce).green
    puts count.to_s.blue
    nonce
  end

  def hash(message)
    Digest::SHA256.hexdigest(message)
  end

  def signature(message, nonce)
    hash(message + nonce)
  end

  def is_valid_nonce?(nonce, message)
    signature(message, nonce).start_with?("0" * target)
  end
end
