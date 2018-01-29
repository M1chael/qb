require 'message'

class Quote < Message
  def initialize(message = nil)
    @table = :quotes
    @type = 'quote'
    
    if message.nil?
      count = (DB[:quotes].count / 10.to_f).ceil
      post_count = rand(99) > 29 ? '' : 'post_count,'
      DB["SELECT * FROM quotes WHERE id IN (SELECT id FROM quotes ORDER BY 
        #{post_count} post_date, id LIMIT #{count}) ORDER BY RANDOM();"].
        all.first.each do |name, value|
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
    return "#{@text}\n\n#{author}\n\"#{book}\""
  end

  def message=(message)
    @post_date = Time.now.to_i
    @post_count += 1
    DB[:quotes].where(id: @id).update(post_date: @post_date, post_count: @post_count)
    super
  end
end
