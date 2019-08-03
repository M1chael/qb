require 'sequel'
require 'rss'
require 'uri'
require 'net/http'

module Rss_reader
  Rss = Struct.new(:link, :id, :channel, :title, :author)

  def read_rss(url)
    uri = URI(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri, {'User-Agent' => 'Telegram bot; 0x22aa2@gmail.com'})
    feed = RSS::Parser.parse(https.request(req).body)
    link = feed.items.first.link
    channel = feed.channel.title
    title = feed.items.first.title
    author = feed.items.first.author
    id = link.split('.')[-2].split('/')[-1].to_i
    return DB[:posts][id: id].nil? ? Rss.new(link, id, channel, title, author) : nil
  end
end
