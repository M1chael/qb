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

  def callback(options)
    quote = Quote.new(options[:mid])
    Telegram::Bot::Client.run(@token) do |telegram| 
      if options[:data] == 'vote'
        if quote.feedback(options[:uid])
          text = 'Спасибо'
          telegram.api.edit_message_reply_markup(chat_id: @chat_id, message_id: options[:mid], 
            reply_markup: markup(quote.score))
        else
          text = 'Вы уже выразили признательность за эту цитату'
        end
        telegram.api.answer_callback_query(callback_query_id: options[:id], text: text)
      end
    end
  end

  private

  def markup(score)
    kb = [[Telegram::Bot::Types::InlineKeyboardButton.new(text: score.to_s, callback_data: 'score'), 
      Telegram::Bot::Types::InlineKeyboardButton.new(text: @vote, callback_data: 'vote')]]
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)    
  end
end
