require 'sequel'
require 'rss_reader'

class Post
  attr_reader :text, :score

  def initialize(options)
    rss = Rss_reader.new(options[:link])

    if options[:mid].nil?
      @id = rss.pid
      @score = 0
      @link = rss.link
    else
      @message = options[:mid]
      id = DB[:messages][mid: @message][:eid]
      DB[:posts][id: id].each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end
  end

  def text
    @link
  end

  def message=(message)
    @message = message
    DB[:posts].insert(id: @id, link: @link, score: 0)
    DB[:messages].insert(mid: @message, eid: @id, type: 'post')
  end

  def feedback(user)
    if !result = DB[:feedback].where(mid: @message, uid: user).count == 0 ? false : true
      @score += 1
      DB[:posts].where(id: @id).update(score: @score)
      DB[:feedback].insert(mid: @message, uid: user)
    end
    return result
  end
end
