require 'quote'
require 'spec_helper'

describe Quote do
  before(:example) do
    DB[:quotes].delete
    DB[:messages].delete
    DB[:quotes].insert(id: 1, text: 'quote1', author: 0, book: 0, 
      post_date: 10, post_count: 2, score: 0)
    DB[:quotes].insert(id: 2, text: 'quote2', author: 0, book: 0, 
      post_date: 11, post_count: 1, score: 0)
    DB[:messages].insert(mid: 1, eid: 1)
    DB[:messages].insert(mid: 2, eid: 1)
    DB[:messages].insert(mid: 3, eid: 2)
    DB[:authors].insert(id: 0, name: 'author')
    DB[:books].insert(id: 0, name: 'book')
  end

  describe '#new' do
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

    it 'choose quote by TG message id' do
      quote = Quote.new(3)
      expect(quote.id).to eq(2)
    end
  end

  describe '#text' do
    it 'returns quote text, author and book name' do
      quote = Quote.new(1)
      expect(quote.text).to eq("quote1\n\nauthor\n\"book\"")
    end
  end

  describe '#message=' do
    before(:example) do
      allow(Time).to receive(:now) { 15 }
      srand(10)
      @quote = Quote.new
      @quote.message = 4
    end

    {post_date: 15, post_count: 2}.each do |name, value|
      it "updates #{name.to_s.sub('_', ' ')} of quote" do
        expect(@quote.send(:"#{name}")).to eq(value)
      end

      it "updates #{name.to_s.sub('_', ' ')} of quote in DB" do
        expect(DB[:quotes][id: @quote.id][:"#{name}"]).to eq(value)
      end
    end
  end

  it_behaves_like 'a Message'
end
