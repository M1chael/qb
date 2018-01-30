#!/usr/bin/env ruby
require_relative '../lib/bootstrap.rb'

case ARGV[0]
when '--quote', '-q'
  @bot.post(:quote)
when '--rss', '-r'
  @bot.post(:post)
else
  @logger.fatal("Wrong argument: \"#{ARGV[0].to_s}\"")
end
