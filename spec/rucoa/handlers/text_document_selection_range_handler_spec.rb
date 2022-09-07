# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Handlers::TextDocumentSelectionRangeHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: request,
        server: server
      )
    end

    before do
      server.source_store.set(uri, content)
    end

    let(:request) do
      {
        'id' => 1,
        'method' => 'textDocument/selectionRange',
        'params' => {
          'positions' => [
            { 'character' => 3, 'line' => 0 }
          ],
          'textDocument' => {
            'uri' => uri
          }
        }
      }
    end

    let(:server) do
      Rucoa::Server.new(
        input: StringIO.new,
        output: StringIO.new
      )
    end

    let(:file_path) do
      'example.rb'
    end

    let(:uri) do
      "file://#{file_path}"
    end

    let(:content) do
      <<~RUBY
        'foo'
      RUBY
    end

    context 'with valid condition' do
      it 'responds server capabilities' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => [
                {
                  'parent' => {
                    'parent' => nil,
                    'range' => {
                      'end' => { 'character' => 5, 'line' => 0 },
                      'start' => { 'character' => 0, 'line' => 0 }
                    }
                  },
                  'range' => {
                    'end' => { 'character' => 4, 'line' => 0 },
                    'start' => { 'character' => 1, 'line' => 0 }
                  }
                }
              ]
            )
          ]
        )
      end
    end
  end
end