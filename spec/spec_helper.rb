$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sequel'

DB = Sequel.sqlite(File.expand_path('../../assets/quotes.db', __FILE__))
