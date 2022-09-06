# frozen_string_literal: true

require 'fileutils'
require 'stringio'
require 'tmpdir'

RSpec.describe Rucoa::Server do
  describe '#start' do
    subject do
      instance.start
    end

    before do
      File.write(file_path, content)

      writer = Rucoa::MessageWriter.new(input)
      input_messages.each do |message|
        writer.write(message)
      end
      input.rewind
    end

    after do
      FileUtils.rm_rf(temporary_directory_path)
    end

    # To avoid loading rucoa's .rubocop.yml in testing at `RuboCop::ConfigStore#for_pwd`.
    around do |example|
      Dir.chdir(temporary_directory_path) do
        example.run
      end
    end

    let(:instance) do
      described_class.new(
        input: input,
        output: output
      )
    end

    let(:input) do
      StringIO.new
    end

    let(:output) do
      StringIO.new
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        path: file_path
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

    let(:temporary_directory_path) do
      Dir.mktmpdir
    end

    let(:input_messages) do
      []
    end

    let(:output_messages) do
      output.rewind
      Rucoa::MessageReader.new(output).read.to_a
    end

    context 'when RuboCop is configured and diagnostics are found' do
      before do
        File.write(
          "#{temporary_directory_path}/.rubocop.yml",
          <<~YAML
            AllCops:
              NewCops: enable
          YAML
        )
      end

      let(:content) do
        <<~RUBY
          'foo'
        RUBY
      end

      let(:input_messages) do
        [
          {
            id: 1,
            method: 'textDocument/didOpen',
            params: {
              textDocument: {
                text: content,
                uri: "file://#{file_path}"
              }
            }
          }
        ]
      end

      it 'outputs diagnostics' do
        subject
        expect(output_messages).to match(
          [
            hash_including(
              'method' => 'textDocument/publishDiagnostics'
            )
          ]
        )
      end
    end

    context 'when selection ranges are requested' do
      let(:input_messages) do
        [
          {
            id: 1,
            method: 'textDocument/didOpen',
            params: {
              textDocument: {
                text: content,
                uri: "file://#{file_path}"
              }
            }
          },
          {
            id: 2,
            method: 'textDocument/selectionRange',
            params: {
              positions: [
                {
                  character: 0,
                  line: 2
                }
              ],
              textDocument: {
                uri: "file://#{file_path}"
              }
            }
          }
        ]
      end

      it 'outputs selection ranges' do
        subject
        expect(output_messages).to match(
          [
            hash_including(
              'method' => 'textDocument/publishDiagnostics'
            ),
            hash_including(
              'id' => 2
            )
          ]
        )
      end
    end
  end
end
