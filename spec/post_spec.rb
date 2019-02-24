require 'post'
require 'spec_helper'

describe Post do
  let(:rss_fields) { {id: 3, link: 'http://post.html', channel: 'Имя канала', 
    title: 'Заголовок поста', author: 'alex_rozoff'} }
  let(:rss) { double }

  before(:example) do
    DB[:posts].delete
    DB[:messages].delete
    DB[:posts].insert(id: 11, score: 1)
    DB[:posts].insert(id: 21, score: 2)
    DB[:messages].insert(mid: 1, eid: 11, type: 'post')
    DB[:messages].insert(mid: 2, eid: 11, type: 'post')
    DB[:messages].insert(mid: 3, eid: 21, type: 'post')
    allow_any_instance_of(Rss_reader).to receive(:read_rss).and_return(rss)
    rss_fields.each{ |field, value| allow(rss).to receive(field).and_return(value) }
  end

  describe '#new' do
    it 'choose post by TG message id' do
      post = Post.new(2)
      expect(post.score).to eq(1)
    end
  end

  describe '#text' do
    it 'returns last post title as link to the post, LJ author name and LJ channel name' do
      post = Post.new
      expect(post.text).
        to eq("<a href=\"#{rss_fields[:link]}\">#{rss_fields[:title]}</a>\n\n#{rss_fields[:author]}\n\"#{rss_fields[:channel]}\"")
    end

    it 'returns nil' do
      allow_any_instance_of(Rss_reader).to receive(:read_rss).and_return(nil)
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
      expect(DB[:posts][id: 3][:link]).to eq(rss_fields[:link])
    end

    it 'saves post to DB with 0 score' do
      expect(DB[:posts][id: 3][:score]).to eq(0)
    end
  end

  it_behaves_like 'a Message'
end
