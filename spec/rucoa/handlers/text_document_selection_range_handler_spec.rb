# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::TextDocumentSelectionRangeHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: request,
        server: server
      )
    end

    before do
      server.source_store.update(source)
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
      Rucoa::Server.new
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

    let(:source) do
      Rucoa::Source.new(
        content: content,
        uri: uri
      )
    end

    context 'with valid condition' do
      it 'responds selection ranges' do
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
