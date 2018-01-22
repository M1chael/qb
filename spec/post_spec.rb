require 'post'
require 'spec_helper'

describe Post do
  let(:link) { 'http://post.html' }
  let(:rss) { instance_double('Rss_reader') }

  before(:example) do
    DB[:posts].delete
    DB[:messages].delete
    DB[:posts].insert(id: 1, score: 1)
    DB[:posts].insert(id: 2, score: 2)
    DB[:messages].insert(mid: 1, eid: 1, type: 'post')
    DB[:messages].insert(mid: 2, eid: 1, type: 'post')
    DB[:messages].insert(mid: 3, eid: 2, type: 'post')
    allow(Rss_reader).to receive(:new).and_return(rss)
    allow(rss).to receive(:link).and_return(link)
    allow(rss).to receive(:pid).and_return(3)
  end

  describe '#new' do
    it 'choose post by TG message id' do
      post = Post.new(mid: 2, link: link)
      expect(post.score).to eq(1)
    end
  end

  describe '#text' do
    it 'returns rss link' do
      post = Post.new(link: link)
      expect(post.text).to eq(link)
    end

    it 'returns nil' do
      allow(rss).to receive(:link).and_return(nil)
      post = Post.new(link: link)
      expect(post.text).to eq(nil)
    end
  end

  describe '#message=' do
    before(:example) do
      @post = Post.new(link: link)
      @post.message = 4
    end

    it 'saves post to DB' do
      expect(DB[:posts][id: 3][:link]).to eq(link)
    end

    it 'saves post to DB with 0 score' do
      expect(DB[:posts][id: 3][:score]).to eq(0)
    end

    it 'saves message to DB' do
      expect(DB[:messages][mid: 4][:eid]).to eq(3)
    end

    it 'saves message to DB with "post" type' do
      expect(DB[:messages][mid: 4][:type]).to eq('post')
    end
  end

  describe '#feedback' do
    before(:example) do
      DB[:feedback].delete
      DB[:feedback].insert(mid: 1, uid: 1)
      DB[:feedback].insert(mid: 2, uid: 2)
      DB[:feedback].insert(mid: 3, uid: 1)
      @post = Post.new(link: link, mid: 1)
    end

    context 'when post feedbacked' do
      before(:example) do
        @result = @post.feedback(1)
      end

      it 'returns true for post feedbacked by user through message' do
        expect(@result).to be true
      end

      it 'does not increase score of post' do
        expect(@post.score).to eq(1)
      end

      it 'does not increase score of post in DB' do
        expect(DB[:posts][id: 1][:score]).to eq(1)
      end
    end

    context 'when post feedbacked' do
      before(:example) do
        @result = @post.feedback(2)
      end

      it 'returns false for post not feedbacked by user through message' do
        expect(@result).to be false
      end

      it 'increases score of post' do
        expect(@post.score).to eq(2)
      end

      it 'increases score of post in DB' do
        expect(DB[:posts][id: 1][:score]).to eq(2)
      end

      it 'saves feedback to DB' do
        expect(DB[:feedback][mid: 1, uid: 2]).not_to be_nil
      end
    end
  end
end
