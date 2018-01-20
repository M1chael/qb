require 'bot'
require 'quote'
require 'spec_helper'

describe Bot do
  {mid: 5, vote: 'vote', token: 'telegram_token', chat_id: 'chat_id', id: 2, 
    text: 'text', author: 1, book: 1, score: 0}.each{ |key, value| let(key) { value } }
  let(:bot) { Bot.new(token: token, chat_id: chat_id, vote: vote) }
  let(:quote) { instance_double('Quote', id: id, text: text, 
    author: author, book: book, score: score) }
  let(:telegram) { double }
  let(:api) { double }
  let(:response) { {'result' => {'message_id' => mid}} }

  before(:example) do
    allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
      with(text: '0', callback_data: 'rating').and_return('lb')
    allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
      with(text: vote, callback_data: 'thx').and_return('rb')
    allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
      with(inline_keyboard: [['lb', 'rb']]).and_return('markup')
    allow(quote).to receive(:message=)
  end

  describe '#post' do
    before(:example) do
      allow(telegram).to receive(:api).and_return(api)
      allow(api).to receive(:send_message).and_return(response)
      allow(Telegram::Bot::Client).to receive(:run).with(token).and_yield(telegram)
      allow(Time).to receive(:now) {post_date}
    end

    it 'sends quote to channel' do
      expect(Telegram::Bot::Client).to receive(:run).with(token).and_yield(telegram)
      expect(telegram).to receive(:api)
      msg = "#{text}\n\n#{author}\n\"#{book}\""
      expect(api).to receive(:send_message).with(chat_id: chat_id, text: msg, reply_markup: 'markup')
      bot.post(quote)
    end

    # it 'updates database' do
    #   DB[:quotes].delete
    #   DB[:messages].delete
    #   DB[:quotes].insert(text: 'quote1', author: 0, book: 0, post_count: 0, post_date: 0, score: 0)
    #   DB[:quotes].insert(text: text, author: author, book: book, post_count: 0, post_date: 0, score: 0)
    #   quotes = DB[:quotes].all
    #   quotes[1][:post_count] = post_count + 1
    #   quotes[1][:post_date] = post_date
    #   bot.post(quote)
    #   expect(DB[:quotes].all).to eq(quotes)
    #   expect(DB[:messages].all).to eq([{mid: mid, qid: id}])
    # end
    it 'sends message to quote with TG mid' do
      expect(quote).to receive(:message=).with(mid)
      bot.post(quote)
    end
  end
end
