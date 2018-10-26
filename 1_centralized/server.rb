require "bundler/setup"
Bundler.require

# Set up Globals
$accounts = {
  "aaron" => 10_000_000
}
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

  post "/send_money" do
    from = params[:from]
    to = params[:to]
    amount = params[:amount].to_i
    $accounts[from] -= amount
    $accounts[to] += amount
    print_accounts
    halt 200
  end
end
