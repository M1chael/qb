require 'message'

class Quote < Message
  def initialize(message = nil)
    @table = :quotes
    @type = 'quote'
    
    if message.nil?
      chance = rand(10)

      case chance
      when 0..1
        query = DB[:quotes].where(Sequel.lit('`id` IN (SELECT `id` FROM `quotes` ORDER BY `post_count`, 
          RANDOM() LIMIT(SELECT CAST(COUNT(*)*0.3 AS INT)+1 FROM `quotes`))')).order(:post_date)
      when 2..8
        query = DB[:quotes].where(Sequel.lit('`id` IN (SELECT `id` FROM `quotes` ORDER BY `post_date` LIMIT 
          (SELECT CAST(COUNT(*)*0.3 AS INT)+1 FROM `quotes`))')).order(Sequel.lit('`post_count`, RANDOM()'))
      else
        query = DB[:quotes].order(Sequel.lit('RANDOM()'))
      end

      query.first.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    else
      @message = message
      id = DB[:messages][mid: message][:eid]
      DB[:quotes][id: id].each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end
  end

  def text
    author = DB[:authors][id: @author][:name]
    book = DB[:books][id: @book][:name]
    return sanitize("#{@text}\n\n#{author}\n\"#{book}\"")
  end

  def message=(message)
    @post_date = Time.now.to_i
    @post_count += 1
    DB[:quotes].where(id: @id).update(post_date: @post_date, post_count: @post_count)
    super
  end
end
