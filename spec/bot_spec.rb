require 'bot'
require 'quote'
require 'spec_helper'

describe Bot do
  {token: 'telegram_token', chat_id: 'chat_id', text: 'text', author: 'author', 
    book: 'book', post_count: 0, post_date: 123456, score: 0}.each{ |key, value| let(key) { value } }
  let(:bot) { Bot.new(token: token, chat_id: chat_id) }
  let(:quote) { instance_double('Quote', text: text, author: author, book: book, 
    post_count: post_count, post_date: post_date, score: score) }
  let(:telegram) { double }
  let(:api) { double }

  before(:example) do
    allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
      with(text: '0', callback_data: 'rating').and_return('lb')
    allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
      with(text: "✋️ Спасибо", callback_data: 'thx').and_return('rb')
    allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
      with(inline_keyboard: [['lb', 'rb']]).and_return('markup')
  end

  describe '#post' do
    before(:example) do
      allow(telegram).to receive(:api).and_return(api)
    end

    it 'sends quote to channel' do
      expect(Telegram::Bot::Client).to receive(:run).with(token).and_yield(telegram)
      expect(telegram).to receive(:api)
      expect(api).to receive(:send_message).with(chat_id: chat_id, text: text, reply_markup: 'markup')
      bot.post(quote)
    end
  end
end
