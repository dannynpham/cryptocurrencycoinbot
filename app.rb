require 'sinatra'
require 'httparty'
require 'json'
require 'nokogiri'
require 'open-uri'

URL = "https://coinmarketcap.com/coins/views/all/"

get '/' do
  'Nothing to see here.'
end

post '/gateway' do
  symbol = params[:text].gsub(params[:trigger_word], '').strip.upcase

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

  currency = currencies[symbol]

  if currency
    respond_message "#{currency['name']} is currently valued at #{currency['price']}"
  elsif symbol == 'HELP'
    respond_message "To use me type 'price <cryptocurrency symbol>'."
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
