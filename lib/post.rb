require 'message'
require 'rss_reader'

class Post < Message
  attr_reader :text, :score

  def initialize(message = nil)
    @table = :posts
    @type = 'post'
    rss = Rss_reader.new(LINK)

    if message.nil?
      @id = rss.id
      @score = 0
      @link = rss.link
    else
      @message = message
      id = DB[:messages][mid: @message][:eid]
      DB[@table][id: id].each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end
  end

  def text
    @link
  end

  def message=(message)
    DB[@table].insert(id: @id, link: @link, score: 0)
    super
  end
end
