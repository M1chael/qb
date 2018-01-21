$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'webmock/rspec'
require 'sequel'

DB = Sequel.sqlite(File.expand_path('../../assets/quotes.db', __FILE__))

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
