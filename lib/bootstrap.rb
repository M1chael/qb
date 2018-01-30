$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'yaml'
require 'bot'

wd = File.join(File.expand_path(File.dirname(__FILE__)), '..')
@config = YAML.load_file(File.join(wd, 'assets', 'config.yml'))
DB = Sequel.sqlite(File.join(wd, 'assets', @config[:db]))
LINK = @config[:rss]
@logger = Logger.new(File.join(wd, @config[:log]), 'monthly')
@bot = Bot.new(token: @config[:telegram_token], chat_id: @config[:chat_id], 
  vote: @config[:vote], logger: @logger)
