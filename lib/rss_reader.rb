require 'rss'
require 'uri'

class Rss_reader
  attr_reader :link

  def initialize(url)
    uri = URI(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Get.new(uri, {'User-Agent' => 'Telegram bot; 0x22aa2@gmail.com'})
    feed = RSS::Parser.parse(https.request(req).body)
    link = feed.items.first.link
    post = link.split('.')[-2].split('/')[-1].to_i
    @link = DB[:rss][pid: post].nil? ? link : nil
  end
end
