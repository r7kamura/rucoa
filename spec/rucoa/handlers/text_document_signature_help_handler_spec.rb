# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Handlers::TextDocumentSignatureHelpHandler do
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
        'method' => 'textDocument/signatureHelp',
        'params' => {
          'position' => position.to_vscode_position,
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

    let(:uri) do
      'file:///path/to/file.rb'
    end

    let(:content) do
      <<~RUBY
        class Foo
          def bar
            '1'.to_i
          end
        end
      RUBY
    end

    let(:position) do
      Rucoa::Position.new(
        column: 12,
        line: 3
      )
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        uri: uri
      )
    end

    context 'when signature help is disabled' do
      before do
        server.configuration.disable_signature_help
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

    context 'when receiver is instance variable (not send node)' do
      let(:content) do
        <<~RUBY
          @foo.to_i
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 9,
          line: 1
        )
      end

      it 'responds empty result' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => {
                'signatures' => []
              }
            )
          ]
        )
      end
    end

    context 'with valid condition' do
      it 'responds signature help' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => {
                'signatures' => [
                  {
                    'documentation' => /\AReturns the result of interpreting/,
                    'label' => 'String#to_i(?::int base) -> Integer'
                  }
                ]
              }
            )
          ]
        )
      end
    end
  end
end
