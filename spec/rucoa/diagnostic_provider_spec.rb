# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

RSpec.describe Rucoa::DiagnosticProvider do
  describe '.call' do
    subject do
      described_class.call(
        source: source,
        uri: uri
      )
    end

    before do
      File.write(file_path, content)
    end

    after do
      FileUtils.rm_rf(temporary_direcotry_path)
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
      "#{temporary_direcotry_path}/example.rb"
    end

    let(:temporary_direcotry_path) do
      Dir.mktmpdir
    end

    let(:uri) do
      "file://#{file_path}"
    end

    shared_context 'when RuboCop is configured' do
      before do
        File.write(
          "#{temporary_direcotry_path}/.rubocop.yml",
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
          # frozen_string_literal: true

          "foo"
        RUBY
      end
    end

    context 'when RuboCop is not configured' do
      include_context 'with some offenses'

      it 'returns empty diagnostics' do
        is_expected.to eq([])
      end
    end

    context 'with no offense' do
      include_context 'when RuboCop is configured'

      it 'returns empty diagnostics' do
        is_expected.to eq([])
      end
    end

    context 'with some offenses' do
      include_context 'when RuboCop is configured'
      include_context 'with some offenses'

      it 'returns some diagnostics' do
        is_expected.to match(
          [
            {
              code: 'Style/StringLiterals',
              data: {
                cop_name: 'Style/StringLiterals',
                edits: [
                  {
                    newText: "'foo'",
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
                  }
                ],
                path: file_path,
                range: a_kind_of(Hash),
                uri: uri
              },
              message: /\APrefer single-quoted strings/,
              range: {
                end: {
                  character: 5,
                  line: 2
                },
                start: {
                  character: 0,
                  line: 2
                }
              },
              severity: 3,
              source: 'RuboCop'
            }
          ]
        )
      end
    end
  end
end
