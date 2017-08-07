require 'sinatra'
require 'httparty'
require 'json'
require 'nokogiri'
require 'open-uri'

URL = "https://coinmarketcap.com/currencies/views/all/"

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
    currencies[currency_sym]["name"] = row.css('img').attr('alt').value
    currencies[currency_sym]["marketcap"] = row.css('.market-cap').text.strip
    currencies[currency_sym]["price"] = row.css('.price').text
  end

  currency = currencies[symbol]

  if currency
    respond_message "#{currency['name']} is currently valued at #{currency['price']}."
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
