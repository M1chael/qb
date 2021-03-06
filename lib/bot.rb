require 'message_factory'
require 'telegram/bot'

class Bot
	def initialize(options)
    options.each{ |key, value| instance_variable_set("@#{key}", value) }
    @message_factory = Message_factory.new
	end

  def post(type)
    msg = @message_factory.get_message(type: type)
    if !msg.text.nil?
      begin
        Telegram::Bot::Client.run(@token, logger: @logger) do |telegram|
          @response = telegram.api.
            send_message(chat_id: @chat_id, text: msg.text, reply_markup: markup(msg.score), parse_mode: 'HTML')
          telegram.logger.info("#{type} with message_id #{@response['result']['message_id']} sended")
        end
        msg.message = @response['result']['message_id']
      rescue => error
        @logger.fatal(error)
        @logger.debug("Request: {chat_id: #{@chat_id}, text: #{msg.text}, 
            reply_markup: #{markup(msg.score)}, parse_mode: 'Markdown'}")
      end
    end
  end

  def callback(options)
    msg = @message_factory.get_message(mid: options[:mid])
    begin
      Telegram::Bot::Client.run(@token, logger: @logger) do |telegram|
        telegram.logger.info("feedback received: #{options.to_s}")
        if options[:data] == 'vote'
          if msg.feedback(options[:uid])
            text = 'Спасибо'
            telegram.api.edit_message_reply_markup(chat_id: @chat_id, message_id: options[:mid], 
              reply_markup: markup(msg.score))
          else
            text = 'Вы уже выразили признательность ранее'
          end
          telegram.api.answer_callback_query(callback_query_id: options[:id], text: text)
        end
      end
    rescue => error
      @logger.fatal(error)
    end
  end

  private

  def markup(score)
    kb = [[Telegram::Bot::Types::InlineKeyboardButton.new(text: score.to_s, callback_data: 'score'), 
      Telegram::Bot::Types::InlineKeyboardButton.new(text: @vote, callback_data: 'vote')]]
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)    
  end
end
