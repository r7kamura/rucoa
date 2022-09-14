# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::TextDocumentDidCloseHandler do
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
        'method' => 'textDocument/didClose',
        'params' => {
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
      'file://example.rb'
    end

    shared_examples 'publishes empty diagnostics' do
      it 'publishes empty diagnostics' do
        subject
        expect(server.responses).to match(
          [
            {
              'jsonrpc' => '2.0',
              'method' => 'textDocument/publishDiagnostics',
              'params' => {
                'diagnostics' => [],
                'uri' => uri
              }
            }
          ]
        )
      end
    end

    context 'with valid condition' do
      include_examples 'publishes empty diagnostics'
    end
  end
end
