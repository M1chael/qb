require 'sequel'

class Quote
  attr_reader :id, :text, :author, :book, :post_count, :post_date, :score

  def message=(message)

  end
end
