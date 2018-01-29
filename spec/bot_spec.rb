require 'bot'
require 'spec_helper'

describe Bot do
  {mid: 5, vote: 'vote', token: 'telegram_token', chat_id: 'chat_id', id: 2, 
    text: "text\n\n1\n\"1\"", author: 1, book: 1, score: 0}.each{ |key, value| let(key) { value } }
  let(:bot) { Bot.new(token: token, chat_id: chat_id, vote: vote) }
  let(:quote) { instance_double('Quote', id: id, text: text, 
    author: author, book: book, post_date: 10, post_count: 1, score: score) }
  let(:telegram) { double }
  let(:api) { double }
  let(:response) { {'result' => {'message_id' => mid}} }
  let(:message_factory) { instance_double('Message_factory') }

  before(:example) do
    allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
      with(text: '0', callback_data: 'score').and_return('lb')
    allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
      with(text: vote, callback_data: 'vote').and_return('rb')
    allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
      with(inline_keyboard: [['lb', 'rb']]).and_return('markup')
    allow(quote).to receive(:message=)
    allow(Message_factory).to receive(:new).and_return(message_factory)
    allow(message_factory).to receive(:get_message)
  end

  describe '#post' do
    before(:example) do
      allow(telegram).to receive(:api).and_return(api)
      allow(api).to receive(:send_message).and_return(response)
      allow(Telegram::Bot::Client).to receive(:run).with(token).and_yield(telegram)
      allow(message_factory).to receive(:get_message).and_return(quote)
    end

    it 'sends quote to channel' do
      expect(Telegram::Bot::Client).to receive(:run).with(token).and_yield(telegram)
      expect(telegram).to receive(:api)
      expect(api).to receive(:send_message).with(chat_id: chat_id, text: text, reply_markup: 'markup')
      bot.post(:quote)
    end

    it 'sends message to quote with TG mid' do
      expect(quote).to receive(:message=).with(mid)
      bot.post(:quote)
    end
  end

  describe '#callback' do
    let(:message) { double }

    before(:example) do
      msg = Struct.new(:message_id)
      @id = 100
      @msg_id = msg.new(11)
      from = Struct.new(:id)
      @from_id = from.new(13)
      @data = 'vote'
      @markup10 = 'markup10'
      allow(Quote).to receive(:new).with(@msg_id.message_id).and_return(quote)
      allow(quote).to receive(:feedback)
      allow(message).to receive(:data).and_return(@data)
      allow(message).to receive(:id).and_return(@id)
      allow(message).to receive(:message).and_return(@msg_id)
      allow(message).to receive(:from).and_return(@from_id)
      allow(telegram).to receive(:listen).and_return(message)
      allow(telegram).to receive(:api).and_return(api)
      allow(api).to receive(:answer_callback_query)
      allow(api).to receive(:edit_message_reply_markup)
      allow(Telegram::Bot::Client).to receive(:run).with(token).and_yield(telegram)
      allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
        with(text: '10', callback_data: 'score').and_return('lb10')      
      allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).
        with(text: vote, callback_data: vote).and_return('rb')
      allow(Telegram::Bot::Types::InlineKeyboardMarkup).to receive(:new).
        with(inline_keyboard: [['lb10', 'rb']]).and_return(@markup10)
      allow(message_factory).to receive(:get_message).and_return(quote)
    end

    it 'shows ok-alert for first time vote' do
      allow(quote).to receive(:feedback).with(@from_id.id).and_return(true)
      expect(api).to receive(:answer_callback_query).with(callback_query_id: @id, text: 'Спасибо')
      bot.callback(data: @data, uid: @from_id.id, mid: @msg_id.message_id, id: @id)
    end

    it 'shows no-vote-alert for re-vote' do
      allow(quote).to receive(:feedback).with(@from_id.id).and_return(false)
      expect(api).to receive(:answer_callback_query).with(callback_query_id: @id, 
        text: 'Вы уже выразили признательность ранее')
      bot.callback(data: @data, uid: @from_id.id, mid: @msg_id.message_id, id: @id)
    end

    it 'updates scores on the button after voting' do
      allow(quote).to receive(:feedback).with(@from_id.id).and_return(true)
      allow(quote).to receive(:score).and_return(10)
      expect(api).to receive(:edit_message_reply_markup).with(chat_id: chat_id, 
        message_id: @msg_id.message_id, reply_markup: @markup10)
      bot.callback(data: @data, uid: @from_id.id, mid: @msg_id.message_id, id: @id)
    end
  end
end
