require 'rss_reader'
require 'spec_helper'

describe Rss_reader do
  before(:example) do
    DB[:posts].delete
    @rss = Rss_reader.new(LINK)
  end

  describe '#link' do
    it 'returns last link from rss feed if it is not in DB yet' do
      expect(@rss.link).to eq('https://alex-rozoff.livejournal.com/45102.html')
    end

    it 'returns nil if last link already in DB' do
      DB[:posts].insert(id: 45102, score: 0)
      rss = Rss_reader.new(LINK)
      expect(rss.link).to be_nil
    end
  end

  describe '#pid' do
    it 'returns post id' do
      expect(@rss.id).to eq(45102)
    end
  end

  describe '#name' do
    it 'returns channel title' do
      expect(@rss.name).to eq('Солнечный ветер')
    end
  end

  describe '#title' do
    it 'returns last item title' do
      expect(@rss.title).to eq('Борьба с глобальным потеплением, как бизнес-афера. Венера атакует.')
    end
  end
end
