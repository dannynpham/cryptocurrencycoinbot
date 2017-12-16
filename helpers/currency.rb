require 'open-uri'
require 'money'

I18n.config.available_locales = :en

module Currency
  URL = "https://api.coinmarketcap.com/v1/ticker/"

  def get_symbols(text, trigger_word)
    text.gsub(trigger_word, '').strip.upcase.split(' ')
  end

  def get_coinwatch_currencies
    currencies = {}
    JSON.parse(open(URL).read).each do |currency|
      currencies[currency['symbol']] = currency
    end
    return currencies
  end

  def get_return_currency(symbol, currency)
    if currency && currency['name'] && currency['price_usd']
      { name: currency['name'], price: currency['price_usd'] }
    elsif currency
      { name: symbol, message: 'Unknown error getting price' }
    else
      { name: symbol, message: 'Unknown currency' }
    end
  end

  def get_return_currencies(symbols, currencies)
    symbols.map{ |symbol| get_return_currency(symbol, currencies[symbol]) }
  end

  def currency_message(currency)
    return "Unknown error." unless currency.is_a?(Hash) && currency[:name]
    if currency[:price]
      price = Money.new(100 * currency[:price].to_f, "USD")
      "#{currency[:name]} is currently valued at #{price.format}"
    elsif currency[:message]
      "#{currency[:name]} - #{currency[:message]}"
    else
      "#{currency[:name]} - Unknown error"
    end
  end

  def currencies_message(currencies)
    currencies.map{ |currency| currency_message(currency) }.join("\n")
  end
end

helpers Currency
