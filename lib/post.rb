require 'message'
require 'rss_reader'

class Post < Message
  include Rss_reader

  def initialize(message = nil)
    @table = :posts
    @type = 'post'
    @rss = read_rss(LINK)

    if message.nil?
      @id = @rss&.id
      @score = 0
    else
      @message = message
      id = DB[:messages][mid: @message][:eid]
      DB[@table][id: id].each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end
  end

  def text
    if @rss
      rss = {title: nil, author: nil, channel: nil}
      rss.each{|field, value| rss[field] = sanitize(@rss.send(field)) }
      return "<a href=\"#{@rss.link}\">#{rss[:title]}</a>\n\n#{rss[:author]}\n\"#{rss[:channel]}\""
    else
      return nil
    end
  end

  def message=(message)
    DB[@table].insert(id: @id, link: @rss.link, score: 0)
    super
  end
end
