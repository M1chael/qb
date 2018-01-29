#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'yaml'
require 'bot'

wd = File.expand_path(File.dirname(__FILE__))
config = YAML.load_file(wd + '/../assets/config.yml')
DB = Sequel.sqlite(File.join(wd, '../assets', config[:db]))
LINK = config[:rss]
logger = Logger.new(wd + '/../' + config[:log], 'monthly')
bot = Bot.new(token: config[:telegram_token], chat_id: config[:chat_id], 
  vote: config[:vote], logger: logger)

case ARGV[0]
when '--quote', '-q'
  bot.post(:quote)
when '--rss', '-r'
  bot.post(:post)
else
  logger.fatal("Wrong argument: \"#{ARGV[0].to_s}\"")
end
