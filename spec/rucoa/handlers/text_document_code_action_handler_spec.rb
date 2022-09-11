# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::TextDocumentCodeActionHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: request,
        server: server
      )
    end

    let(:request) do
      {
        'id' => 1,
        'method' => 'textDocument/codeAction',
        'params' => {
          'context' => {
            'diagnostics' => [
              {
                'code' => 'Style/StringLiterals',
                'data' => {
                  'cop_name' => 'Style/StringLiterals',
                  'edits' => [
                    {
                      'newText' => "'foo'",
                      'range' => range
                    }
                  ],
                  'path' => file_path,
                  'range' => range,
                  'uri' => uri
                },
                'message' => 'Prefer single-quoted strings...',
                'range' => range,
                'severity' => 3,
                'source' => 'RuboCop'
              }
            ]
          },
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

    let(:range) do
      {
        'end' => {
          'character' => 5,
          'line' => 2
        },
        'start' => {
          'character' => 0,
          'line' => 2
        }
      }
    end

    context 'with valid condition' do
      it 'responds code actions' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'jsonrpc' => '2.0',
              'result' => [
                {
                  'diagnostics' => request.dig('params', 'context', 'diagnostics'),
                  'edit' => {
                    'documentChanges' => [
                      {
                        'edits' => [
                          {
                            'newText' => "'foo'",
                            'range' => range
                          }
                        ],
                        'textDocument' => {
                          'uri' => uri,
                          'version' => nil
                        }
                      }
                    ]
                  },
                  'isPreferred' => true,
                  'kind' => 'quickfix',
                  'title' => 'Autocorrect Style/StringLiterals'
                }
              ]
            )
          ]
        )
      end
    end
  end
end
