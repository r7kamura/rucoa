# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Handlers::TextDocumentCompletionHandler do
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
        'method' => 'textDocument/completion',
        'params' => {
          'position' => position.to_vscode_position,
          'textDocument' => {
            'uri' => uri
          }
        }
      }
    end

    let(:server) do
      Rucoa::Server.new
    end

    let(:uri) do
      'file:///path/to/file.rb'
    end

    let(:content) do
      <<~RUBY
        '10'.
      RUBY
    end

    let(:position) do
      Rucoa::Position.new(
        column: 5,
        line: 1
      )
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        uri: uri
      )
    end

    context 'when completion is disabled' do
      before do
        server.configuration.disable_completion
      end

      it 'responds nil result' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => nil
            )
          ]
        )
      end
    end

    context 'with method head part' do
      let(:content) do
        <<~RUBY
          '10'.to_sy
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 10,
          line: 1
        )
      end

      it 'responds completion items' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => [
                hash_including(
                  'label' => 'to_sym'
                )
              ]
            )
          ]
        )
      end
    end

    context 'with method dot' do
      it 'responds completion items' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => array_including(
                hash_including(
                  'label' => 'to_i',
                  'textEdit' => {
                    'newText' => 'to_i',
                    'range' => {
                      'end' => {
                        'character' => 5,
                        'line' => 0
                      },
                      'start' => {
                        'character' => 5,
                        'line' => 0
                      }
                    }
                  }
                )
              )
            )
          ]
        )
      end
    end

    context 'with constant head part' do
      let(:content) do
        <<~RUBY
          File::SE
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 8,
          line: 1
        )
      end

      it 'responds completion items' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => [
                hash_including(
                  'label' => 'SEPARATOR'
                )
              ]
            )
          ]
        )
      end
    end

    context 'with constant ::' do
      let(:content) do
        <<~RUBY
          File::
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 6,
          line: 1
        )
      end

      it 'responds completion items' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => array_including(
                hash_including(
                  'label' => 'PATH_SEPARATOR'
                ),
                hash_including(
                  'label' => 'SEPARATOR'
                )
              )
            )
          ]
        )
      end
    end
  end
end
