require 'sinatra'
Dir[File.join(__dir__, 'helpers', '*.rb')].each {|file| require file }

HELP_MESSAGE = <<-HELP_MESSAGE
To use me type `price [symbol]` or `price [symbol] [symbol] ...`.
(Ex. `price btc` or `price btc eth ltc`)
HELP_MESSAGE

ERROR_MESSAGE = "Must provide 'text' and 'trigger_word' params"

get '/' do
  'Nothing to see here.'
end

post '/gateway' do
  halt 422, ERROR_MESSAGE unless valid_params?
  symbols = get_symbols(params[:text], params[:trigger_word])
  coinwatch_currencies = get_coinwatch_currencies
  return_currencies = get_return_currencies(symbols, coinwatch_currencies)

  if return_currencies.any?
    respond_message currencies_message(return_currencies)
  elsif symbols.first == 'HELP'
    respond_message HELP_MESSAGE
  else
    respond_message ["Unknown command, see help:", HELP_MESSAGE].join("\n")
  end
end
