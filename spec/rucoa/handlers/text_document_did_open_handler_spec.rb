# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

RSpec.describe Rucoa::Handlers::TextDocumentDidOpenHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: request,
        server: server
      )
    end

    around do |example|
      Dir.chdir(temporary_directory_path) do
        example.run
      end
    end

    before do
      File.write(file_path, content)
    end

    after do
      FileUtils.rm_rf(temporary_directory_path)
    end

    let(:request) do
      {
        'id' => 1,
        'method' => 'textDocument/didOpen',
        'params' => {
          'textDocument' => {
            'text' => content,
            'uri' => uri
          }
        }
      }
    end

    let(:server) do
      Rucoa::Server.new
    end

    let(:content) do
      <<~RUBY
        'foo'
      RUBY
    end

    let(:uri) do
      "file://#{file_path}"
    end

    let(:file_path) do
      "#{temporary_directory_path}/example.rb"
    end

    let(:temporary_directory_path) do
      Dir.mktmpdir
    end

    shared_context 'when RuboCop is configured' do
      before do
        File.write(
          "#{temporary_directory_path}/.rubocop.yml",
          <<~YAML
            AllCops:
              NewCops: enable
          YAML
        )
      end
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
      it 'stores source' do
        subject
        source = server.source_store.get(uri)
        expect(source.content).to eq(content)
        expect(source.path).to eq(file_path)
      end
    end

    context 'when RuboCop is not configured' do
      include_examples 'publishes empty diagnostics'
    end

    context 'when diagnostics is disabled' do
      include_context 'when RuboCop is configured'

      before do
        server.configuration.disable_diagnostics
      end

      include_examples 'publishes empty diagnostics'
    end

    context 'when URI is for untitled document' do
      include_context 'when RuboCop is configured'

      let(:uri) do
        'untitled:Untitled-1'
      end

      it 'publishes some diagnostics' do
        subject
        expect(server.responses).to match(
          [
            {
              'jsonrpc' => '2.0',
              'method' => 'textDocument/publishDiagnostics',
              'params' => {
                'diagnostics' => [
                  a_kind_of(Hash)
                ],
                'uri' => uri
              }
            }
          ]
        )
      end
    end

    context 'when RuboCop is configured' do
      include_context 'when RuboCop is configured'

      it 'publishes some diagnostics' do
        subject
        expect(server.responses).to match(
          [
            {
              'jsonrpc' => '2.0',
              'method' => 'textDocument/publishDiagnostics',
              'params' => {
                'diagnostics' => [
                  {
                    'code' => 'Style/FrozenStringLiteralComment',
                    'data' => {
                      'cop_name' => 'Style/FrozenStringLiteralComment',
                      'edits' => [
                        {
                          'newText' => "# frozen_string_literal: true\n",
                          'range' => {
                            'end' => {
                              'character' => 0,
                              'line' => 0
                            },
                            'start' => {
                              'character' => 0,
                              'line' => 0
                            }
                          }
                        }
                      ],
                      'uri' => uri
                    },
                    'message' => 'Missing frozen string literal comment.',
                    'range' => {
                      'end' => {
                        'character' => 1,
                        'line' => 0
                      },
                      'start' => {
                        'character' => 0,
                        'line' => 0
                      }
                    },
                    'severity' => 3,
                    'source' => 'RuboCop'
                  }
                ],
                'uri' => uri
              }
            }
          ]
        )
      end
    end
  end
end
