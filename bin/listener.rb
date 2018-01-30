#!/usr/bin/env ruby
require_relative '../lib/bootstrap.rb'

begin
  Telegram::Bot::Client.run(@config[:telegram_token], logger: @logger) do |telegram|
    telegram.listen do |message|
      if message.respond_to?(:data)
        @bot.callback(data: message.data, uid: message.from.id, mid: message.message.message_id, id: message.id)
      end
    end
  end
rescue => error
  @logger.fatal(error)
end
