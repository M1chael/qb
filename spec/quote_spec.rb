require 'quote'
require 'spec_helper'

describe Quote do
  describe '#new' do
    it 'chooses quote, which post date is older in 70% of cases' do
      srand(50)
      quote = Quote.new
      text = "quote1\n\nauthor\n&quot;book&quot;"
      expect(quote.text).to eq(text)
    end

    it 'chooses quote, which post count is lesser in 30% of cases' do
      srand(10)
      quote = Quote.new
      text = "quote2\n\nauthor\n&quot;book&quot;"
      expect(quote.text).to eq(text)
    end

    it 'choose quote by TG message id' do
      quote = Quote.new(3)
      text = "quote2\n\nauthor\n&quot;book&quot;"
      expect(quote.text).to eq(text)
    end
  end

  describe '#text' do
    it 'returns quote text, author and book name' do
      quote = Quote.new(1)
      expect(quote.text).to eq("quote1\n\nauthor\n&quot;book&quot;")
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
      it "updates #{name.to_s.sub('_', ' ')} of quote in DB" do
        expect(DB[:quotes][id: 2][:"#{name}"]).to eq(value)
      end
    end
  end

  it_behaves_like 'a Message'
end
