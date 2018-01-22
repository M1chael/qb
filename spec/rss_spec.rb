require 'rss_reader'
require 'spec_helper'

describe Rss_reader do
  before(:example) do
    DB[:posts].delete
  end

  describe '#link' do
    it 'returns last link from rss feed if it is not in DB yet' do
      rss = Rss_reader.new('https://alex-rozoff.livejournal.com/data/rss')
      expect(rss.link).to eq('https://alex-rozoff.livejournal.com/45102.html')
    end

    it 'returns nil if last link already in DB' do
      DB[:posts].insert(pid: 45102, score: 0)
      rss = Rss_reader.new('https://alex-rozoff.livejournal.com/data/rss')
      expect(rss.link).to be_nil
    end
  end

  describe '#pid' do
    it 'returns post id' do
      rss = Rss_reader.new('https://alex-rozoff.livejournal.com/data/rss')
      expect(rss.pid).to eq(45102)
    end
  end
end