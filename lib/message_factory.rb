require 'post'
require 'quote'

class Message_factory
  def get_message(options)
    mid = options[:mid]
    type = mid.nil? ? options[:type] : DB[:messages][mid: options[:mid]][:type].to_sym
    case type
    when :post
      mid.nil? ? Post.new : Post.new(mid)
    when :quote
      mid.nil? ? Quote.new : Quote.new(mid)
    end
  end
end
