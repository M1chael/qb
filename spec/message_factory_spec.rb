require 'message_factory'
require 'spec_helper'

describe Message_factory do
  let(:factory) { Message_factory.new }

  describe '#get_message' do
    before(:example) do
      @post = instance_double(Post)
      @quote = instance_double(Quote)
      allow(Post).to receive(:new).and_return(@post)
      allow(Quote).to receive(:new).and_return(@quote)
    end

    it 'returns post' do
      expect(factory.get_message(type: :post)).to eq(@post)
    end

    it 'returns quote' do
      expect(factory.get_message(type: :quote)).to eq(@quote)
    end

    context 'when mid is in place instead of type' do
      before(:example) do
        @post_mid = 1
        @quote_mid = 2
        DB[:messages].delete
        DB[:messages].insert(mid: @post_mid, eid: 2, type: 'post')
        DB[:messages].insert(mid: @quote_mid, eid: 3, type: 'quote')
      end

      it 'returns post by message id' do
        expect(factory.get_message(mid: @post_mid)).to eq(@post)
      end

      it 'returns quote by message id' do
        expect(factory.get_message(mid: @quote_mid)).to eq(@quote)
      end
    end
  end
end
