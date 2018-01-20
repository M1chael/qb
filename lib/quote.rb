require 'sequel'

class Quote
  attr_reader :id, :text, :author, :book, :post_date, :score

  def initialize
    if rand(99) > 29
      count = (DB[:quotes].count / 10.to_f).ceil
      DB["SELECT * FROM quotes WHERE id IN (SELECT id FROM quotes ORDER BY 
        post_date, id LIMIT #{count}) ORDER BY RANDOM();"].
        all.first.each do |name, value|
          instance_variable_set("@#{name}", value)
      end
    else
      DB["SELECT *, COUNT(messages.qid) as Count FROM quotes LEFT JOIN messages 
        ON quotes.id=messages.qid GROUP BY quotes.id ORDER BY Count, post_date, id;"].
        all.first.each do |name, value|
          instance_variable_set("@#{name}", value) if name != :Count
      end
    end
  end

  def message=(message)

  end
end
