require 'sequel'
require 'rss'
require 'uri'
require 'net/http'

class Rss_reader
  attr_reader :link, :id, :name

  def initialize(url)
    uri = URI(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri, {'User-Agent' => 'Telegram bot; 0x22aa2@gmail.com'})
    feed = RSS::Parser.parse(https.request(req).body)
    link = feed.items.first.link
    @name = feed.channel.title
    @id = link.split('.')[-2].split('/')[-1].to_i
    @link = DB[:posts][id: @id].nil? ? link : nil
  end
end
