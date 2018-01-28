$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'webmock/rspec'
require 'sequel'

DB = Sequel.sqlite(File.expand_path('../../assets/quotes.db', __FILE__))
LINK = 'https://alex-rozoff.livejournal.com/data/rss'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |c|
  c.before(:example) do
    stub_request(:get, 'https://alex-rozoff.livejournal.com/data/rss').
      with(:headers => {'User-Agent'=>'Telegram bot; 0x22aa2@gmail.com'}).
      to_return(File.read('test/rss.xml'))
  end

  c.around(:example) do |example|
    DB.transaction(:rollback=>:always, :auto_savepoint=>true) { example.run }
  end
end

RSpec.shared_examples 'a Message' do
  let(:message) { described_class.new } 

  {text: 0, score: 0, 'message=': 1, feedback: 1}.each do |method, arguments|
    it "responds to #{method}" do
      expect(message).to respond_to(method).with(arguments).argument
    end
  end

  describe '#message=' do
    before(:example) do
      @type = 'post'
      message.instance_variable_set(:@type, @type)
      @id = 10
      message.instance_variable_set(:@id, @id)
      @msg = 30
      message.message=(@msg)
    end

    it 'insert message to messages table' do
      expect(DB[:messages][mid: @msg]).to eq({mid: @msg, eid: @id, type: @type})
    end
  end

  describe '#feedback' do
    before(:example) do
      message.instance_variable_set(:@score, 1)
      @id = 1
      message.instance_variable_set(:@id, @id)
      @message = 1
      message.instance_variable_set(:@message, @message)
      @table = :posts
      message.instance_variable_set(:@table, @table)
      DB[:feedback].delete
      DB[:feedback].insert(mid: 1, uid: 1)
      DB[:feedback].insert(mid: 2, uid: 2)
      DB[:feedback].insert(mid: 3, uid: 1)
      DB[@table].insert(id: 1, score: 1)
    end

    context 'when post feedbacked by the user through the message' do
      before(:example) do
        @result = message.feedback(1)
      end

      it 'returns false' do
        expect(@result).to be false
      end

      it 'does not increase score of post' do
        expect(message.score).to eq(1)
      end

      it 'does not increase score of post in DB' do
        expect(DB[@table][id: 1][:score]).to eq(1)
      end
    end

    context 'when post is not feedbacked by the user through the message' do
      before(:example) do
        @result = message.feedback(2)
      end

      it 'returns false' do
        expect(@result).to be true
      end

      it 'increases score of post' do
        expect(message.score).to eq(2)
      end

      it 'increases score of post in DB' do
        expect(DB[@table][id: 1][:score]).to eq(2)
      end

      it 'saves feedback to DB' do
        expect(DB[:feedback][mid: 1, uid: 2]).to eq(mid: @id, uid: 2)
      end
    end
  end
end
