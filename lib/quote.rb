require 'sequel'

class Image
  attr_reader :text, :author, :book
  attr_accessor :post_count, :post_date, :score
end
