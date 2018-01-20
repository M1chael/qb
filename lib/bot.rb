require 'quote'
require 'telegram/bot'

class Bot
	def initialize(options)
    options.each{ |key, value| instance_variable_set("@#{key}", value) }
	end

  def post(quote)
    Telegram::Bot::Client.run(@token) do |telegram|
      text = "#{quote.text}\n\n#{quote.author}\n\"#{quote.book}\""
      @response = telegram.api.send_message(chat_id: @chat_id, text: text, reply_markup: markup(quote.score))
    end
    quote.message = @response['result']['message_id']
  end

  private

  def markup(score)
    kb = [[Telegram::Bot::Types::InlineKeyboardButton.new(text: score.to_s, callback_data: 'score'), 
      Telegram::Bot::Types::InlineKeyboardButton.new(text: @vote, callback_data: 'vote')]]
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)    
  end
end
