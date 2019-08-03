require 'rss_reader'
require 'spec_helper'

describe Rss_reader do
  include Rss_reader

  before(:example) do
    DB[:posts].delete
    @rss = read_rss(LINK)
  end

  describe '#read_rss' do
    it 'returns last link from rss feed if it is not in DB yet' do
      expect(@rss.link).to eq('https://alex-rozoff.livejournal.com/45102.html')
    end

    it 'returns nil if last link already in DB' do
      DB[:posts].insert(id: 45102, score: 0)
      rss = read_rss(LINK)
      expect(rss).to be_nil
    end

    it 'returns post id' do
      expect(@rss.id).to eq(45102)
    end

    it 'returns channel title' do
      expect(@rss.channel).to eq('Солнечный ветер')
    end

    it 'returns last item title' do
      expect(@rss.title).to eq('Борьба с глобальным потеплением, как бизнес-афера. Венера атакует.')
    end

    it 'returns last item author' do
      expect(@rss.author).to eq('alex_rozoff')
    end
  end
end
