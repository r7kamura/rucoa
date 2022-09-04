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
        reader: reader,
        writer: writer
      )
    end

    let(:reader) do
      StringIO.new
    end

    let(:writer) do
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

    # To avoid loading rucoa's .at `testing via #for_pwd`.
    let(:temporary_directory_path) do
      Dir.mktmpdir
    end
    # To avoid loading rucoa's .at `testing via #for_pwd`.

    context 'when RuboCop is configured and diagnostics are found' do
      before do
        reader << Rucoa::MessageWriter.pack(
          id: 1,
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              text: content,
              uri: "file://#{file_path}"
            }
          }
        )
        reader.rewind

        File.write(
          "#{temporary_directory_path}/.rubocop.yml",
          <<~YAML
            AllCops:
            # To avoid loading rucoa's .at `testing via #for_pwd`.
              NewCops: enable
          YAML
        )
      end

      let(:content) do
        <<~RUBY
          'foo'
        RUBY
      end

      it 'writes diagnostics' do
        subject
        expect(writer.string).to eq(
          Rucoa::MessageWriter.pack(
            jsonrpc: '2.0',
            method: 'textDocument/publishDiagnostics',
            params: {
              diagnostics: [
                {
                  code: 'Style/FrozenStringLiteralComment',
                  data: {
                    cop_name: 'Style/FrozenStringLiteralComment',
                    edits: [
                      {
                        newText: "# frozen_string_literal: true\n",
                        range: {
                          end: {
                            character: 0,
                            line: 0
                          },
                          start: {
                            character: 0,
                            line: 0
                          }
                        }
                      }
                    ],
                    path: file_path,
                    range: {
                      end: {
                        character: 1,
                        line: 0
                      },
                      start: {
                        character: 0,
                        line: 0
                      }
                    },
                    uri: "file://#{file_path}"
                  },
                  message: 'Missing frozen string literal comment.',
                  range: {
                    end: {
                      character: 1,
                      line: 0
                    },
                    start: {
                      character: 0,
                      line: 0
                    }
                  },
                  severity: 3,
                  source: 'RuboCop'
                }
              ],
              uri: "file://#{file_path}"
            }
          )
        )
      end
    end

    context 'when selection ranges are requested' do
      before do
        reader << Rucoa::MessageWriter.pack(
          id: 1,
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              text: content,
              uri: "file://#{file_path}"
            }
          }
        )
        reader << Rucoa::MessageWriter.pack(
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
        )
        reader.rewind
      end

      it 'writes selection ranges' do
        subject
        expect(writer.string).to eq(
          Rucoa::MessageWriter.pack(
            jsonrpc: '2.0',
            method: 'textDocument/publishDiagnostics',
            params: {
              diagnostics: [],
              uri: "file://#{file_path}"
            }
          ) +
          Rucoa::MessageWriter.pack(
            id: 2,
            jsonrpc: '2.0',
            result: [
              {
                parent: {
                  parent: nil,
                  range: {
                    end: {
                      character: 5,
                      line: 2
                    },
                    start: {
                      character: 0,
                      line: 2
                    }
                  }
                },
                range: {
                  end: {
                    character: 4,
                    line: 2
                  },
                  start: {
                    character: 1,
                    line: 2
                  }
                }
              }
            ]
          )
        )
      end
    end
  end
end
