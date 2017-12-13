require 'sinatra'
require 'httparty'
require 'json'
require 'nokogiri'
require 'open-uri'

URL = "https://coinmarketcap.com/coins/views/all/"
HELP_MESSAGE = <<-HELP_MESSAGE
To use me type `price [symbol]` or `price [symbol] [symbol] ...`.
(Ex. `price btc` or `price btc eth ltc`)
HELP_MESSAGE

def get_symbols(text, trigger_word)
  text.gsub(trigger_word, '').strip.upcase.split(' ')
end

def currencies_message(currencies)
  currency_messages = currencies.map do |currency|
    "#{currency['name']} is currently valued at #{currency['price']}"
  end
  currency_messages.join("\n")
end

get '/' do
  'Nothing to see here.'
end

post '/gateway' do
  unless params[:text].is_a?(String) && params[:trigger_word].is_a?(String)
    halt 422, "Must provide 'text' and 'trigger_word' params"
  end
  symbols = get_symbols(params[:text], params[:trigger_word])

  currencies = {}

  coinwatch_page = Nokogiri::HTML(open(URL))
  coinwatch_page.css('tbody tr').each do |row|
    # TODO: Short circuit when symbol is matched.
    currency_sym = row.css('.text-left').children.first.text
    currencies[currency_sym] = {}
    currencies[currency_sym]["name"] = row.css('.currency-name-container').text
    currencies[currency_sym]["marketcap"] = row.css('.market-cap').text.strip
    price = row.css('.price').text.split('.')
    price[0] = price[0].reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    currencies[currency_sym]["price"] = price.join('.')
  end

  return_currencies = symbols.map{|symbol| currencies[symbol] }

  if return_currencies.any?
    respond_message currencies_message(return_currencies)
  elsif symbols.first == 'HELP'
    respond_message HELP_MESSAGE
  else
    respond_message "Currency cannot be found."
  end

  # case action
  #   when 'issues'
  #     resp = HTTParty.get(repo_url)
  #     resp = JSON.parse resp.body
  #     respond_message "There are #{resp['open_issues_count']} open issues on #{repo}"
  # end

end

def respond_message message
  content_type :json
  {:text => message}.to_json
end
