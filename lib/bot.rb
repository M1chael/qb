require 'telegram/bot'

class Bot
	def initialize(options)
    options.each{ |key, value| instance_variable_set("@#{key}", value) }
	end

  def markup(thx)
    kb = [[Telegram::Bot::Types::InlineKeyboardButton.new(text: thx.to_s, callback_data: 'rating'), 
      Telegram::Bot::Types::InlineKeyboardButton.new(text: "✋️ Спасибо", callback_data: 'thx')]]
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)    
  end

  def post(quote)
    Telegram::Bot::Client.run(@token) do |telegram| 
      @response = telegram.api.send_message(chat_id: @chat_id, text: quote.text, reply_markup: markup(quote.score))
    end
    # DB[:images].where(link: image.link).update(rating: 0, 
    #   mid: @response['result']['message_id'], fid: @response['result']['photo'][-1]['file_id'])
  end
end
