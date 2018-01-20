require 'quote'
require 'spec_helper'

describe Quote do
  describe '#new' do
    before(:example) do
      DB[:quotes].delete
      DB[:messages].delete
      DB[:quotes].insert(id: 1, text: 'quote1', author: 0, book: 0, post_date: 10, score: 0)
      DB[:quotes].insert(id: 2, text: 'quote2', author: 0, book: 0, post_date: 11, score: 0)
      DB[:messages].insert(mid: 1, qid: 1)
      DB[:messages].insert(mid: 2, qid: 1)
      DB[:messages].insert(mid: 3, qid: 2)
    end

    it 'chooses quote, which post date is older in 70% of cases' do
      srand(50)
      quote = Quote.new
      expect(quote.post_date).to eq(10)
    end

    it 'chooses quote, which post date is older in 30% of cases' do
      srand(10)
      quote = Quote.new
      expect(quote.post_date).to eq(11)
    end
  end
end
