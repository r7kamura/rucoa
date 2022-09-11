# frozen_string_literal: true

require 'stringio'
require 'tmpdir'

RSpec.describe Rucoa::Handlers::TextDocumentDidChangeHandler do
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
        'method' => 'textDocument/didChange',
        'params' => {
          'contentChanges' => [
            {
              'text' => content
            }
          ],
          'textDocument' => {
            'uri' => uri
          }
        }
      }
    end

    let(:server) do
      Rucoa::Server.new(
        io_in: StringIO.new,
        io_out: StringIO.new
      )
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

    context 'with valid condition' do
      it 'stores source and published empty diagnostics' do
        subject
        source = server.source_store.get(uri)
        expect(source.content).to eq(content)
        expect(source.path).to eq(file_path)
      end
    end

    context 'when RuboCop is not configured' do
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
  end
end
