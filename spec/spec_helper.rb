$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sequel'

DB = Sequel.sqlite(File.expand_path('../../assets/quotes.db', __FILE__))

RSpec.configure do |c|
  c.around(:each) do |example|
    DB.transaction(:rollback=>:always, :auto_savepoint=>true) { example.run }
  end
end
