require 'post'
require 'spec_helper'

describe Post do
  let(:link) { 'http://post.html' }
  let(:rss) { instance_double('Rss_reader') }

  before(:example) do
    DB[:posts].delete
    DB[:messages].delete
    DB[:posts].insert(id: 11, score: 1)
    DB[:posts].insert(id: 21, score: 2)
    DB[:messages].insert(mid: 1, eid: 11, type: 'post')
    DB[:messages].insert(mid: 2, eid: 11, type: 'post')
    DB[:messages].insert(mid: 3, eid: 21, type: 'post')
    allow(Rss_reader).to receive(:new).and_return(rss)
    allow(rss).to receive(:link).and_return(link)
    allow(rss).to receive(:id).and_return(3)
  end

  describe '#new' do
    it 'choose post by TG message id' do
      post = Post.new(2)
      expect(post.score).to eq(1)
    end
  end

  describe '#text' do
    it 'returns rss link' do
      post = Post.new
      expect(post.text).to eq(link)
    end

    it 'returns nil' do
      allow(rss).to receive(:link).and_return(nil)
      post = Post.new
      expect(post.text).to eq(nil)
    end
  end

  describe '#message=' do
    before(:example) do
      @post = Post.new
      @post.message = 4
    end

    it 'saves post to DB' do
      expect(DB[:posts][id: 3][:link]).to eq(link)
    end

    it 'saves post to DB with 0 score' do
      expect(DB[:posts][id: 3][:score]).to eq(0)
    end
  end

  it_behaves_like 'a Message'
end
