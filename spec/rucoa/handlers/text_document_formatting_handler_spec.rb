# frozen_string_literal: true

require 'fileutils'
require 'stringio'
require 'tmpdir'

RSpec.describe Rucoa::Handlers::TextDocumentFormattingHandler do
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
      server.source_store.update(source)
    end

    after do
      FileUtils.rm_rf(temporary_directory_path)
    end

    let(:request) do
      {
        'id' => 1,
        'method' => 'textDocument/rangeFormatting',
        'params' => {
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

    let(:content) do
      <<~RUBY
        # frozen_string_literal: true

        'foo'
      RUBY
    end

    let(:file_path) do
      "#{temporary_directory_path}/example.rb"
    end

    let(:uri) do
      "file://#{file_path}"
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        uri: uri
      )
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

    shared_context 'with some offenses' do
      let(:content) do
        <<~RUBY
          'foo'
          "bar"
        RUBY
      end
    end

    context 'when RuboCop is not configured' do
      include_context 'with some offenses'

      it 'returns empty edits' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => []
            )
          ]
        )
      end
    end

    context 'when URI is for untitled file' do
      include_context 'when RuboCop is configured'
      include_context 'with some offenses'

      let(:uri) do
        'untitled:Untitled-1'
      end

      it 'responds some edits' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => [
                a_kind_of(Hash)
              ]
            )
          ]
        )
      end
    end

    context 'when some offenses are found in given range' do
      include_context 'when RuboCop is configured'
      include_context 'with some offenses'

      it 'responds some edits' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => [
                {
                  'newText' => "# frozen_string_literal: true\n\n'foo'\n'bar'\n",
                  'range' => {
                    'end' => {
                      'character' => 6,
                      'line' => 2
                    },
                    'start' => {
                      'character' => 0,
                      'line' => 0
                    }
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
