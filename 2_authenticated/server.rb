require "bundler/setup"
Bundler.require
require_relative "transaction"
require_relative "wallet"

# Set up Globals
$accounts = {}
$accounts.default = 0

class Server < Sinatra::Base
  helpers do
    def print_accounts
      system "clear"
      puts "\n\n\n** Accounts **".green
      $accounts.each do |user, balance|
        puts user.blue + " has a balance of " + balance.to_s.yellow
      end
    end
  end

  configure do
    wallet = Wallet.new
    # For demo convenience
    puts "Wallet pubic key is #{wallet.pub_key}".blue
    File.write("/keys/key.pub", wallet.pub_key)
    puts "Wallet private key is #{wallet.priv_key}".green
    File.write("/keys/key", wallet.priv_key)
  end

  post "/send_money" do
    from = params[:from]
    to = params[:to]
    amount = params[:amount].to_i
    signature = params[:signature]
    trx = Transaction.new(from: from, to: to, amount: amount, signature: signature)
    if trx.valid?
      $accounts[Crypto.hash(from)] -= amount unless from.nil? # first trx
      $accounts[Crypto.hash(to)] += amount
    else
      halt 401
    end
    print_accounts
    halt 201
  end
end
