# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Server do
  describe '#start' do
    subject do
      instance.start
    end

    let(:instance) do
      described_class.new(
        reader: reader,
        writer: writer
      )
    end

    let(:reader) do
      StringIO.new
    end

    let(:writer) do
      StringIO.new
    end

    # @param hash [Hash]
    # @return [String]
    def to_language_server_message(hash)
      body = hash.to_json
      message = +''
      message << "Content-Length: #{body.bytesize}\r\n"
      message << "\r\n"
      message << body
      message
    end

    context 'when selection ranges are requested' do
      before do
        reader << to_language_server_message(
          id: 1,
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              uri: 'file:///foo.rb',
              text: <<~RUBY
                'foo'
              RUBY
            }
          }
        )
        reader << to_language_server_message(
          id: 2,
          method: 'textDocument/selectionRange',
          params: {
            textDocument: {
              uri: 'file:///foo.rb'
            },
            positions: [
              {
                line: 0,
                character: 0
              }
            ]
          }
        )
        reader.rewind
      end

      it 'behaves as expected' do
        subject
        expect(writer.string).to eq(
          to_language_server_message(
            id: 2,
            result: [
              {
                parent: {
                  parent: nil,
                  range: {
                    end: {
                      character: 5,
                      line: 0
                    },
                    start: {
                      character: 0,
                      line: 0
                    }
                  }
                },
                range: {
                  end: {
                    character: 4,
                    line: 0
                  },
                  start: {
                    character: 1,
                    line: 0
                  }
                }
              }
            ],
            jsonrpc: '2.0'
          )
        )
      end
    end
  end
end
