require 'sequel'

class Quote
  attr_reader :id, :text, :author, :book, :post_date, :post_count, :score

  def initialize
    count = (DB[:quotes].count / 10.to_f).ceil
    post_count = rand(99) > 29 ? '' : 'post_count,'
    DB["SELECT * FROM quotes WHERE id IN (SELECT id FROM quotes ORDER BY 
      #{post_count} post_date, id LIMIT #{count}) ORDER BY RANDOM();"].
      all.first.each do |name, value|
        instance_variable_set("@#{name}", value)
    end
  end

  def message=(message)
    @post_date = Time.now.to_i
    @post_count += 1
    DB[:quotes].where(id: @id).update(post_date: @post_date, post_count: @post_count)
  end
end
