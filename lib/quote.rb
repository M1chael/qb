require 'sequel'

class Quote
  attr_reader :id, :text, :author, :book, :post_date, :post_count, :score

  def initialize(message = nil)
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
    DB[:messages].insert(mid: message, eid: @id)
  end

  def feedback(user)
    if !result = DB[:feedback].where(mid: @message, uid: user).count == 0 ? false : true
      @score += 1
      DB[:quotes].where(id: @id).update(score: @score)
      DB[:feedback].insert(mid: @message, uid: user)
    end
    return result
  end
end
