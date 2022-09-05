# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

RSpec.describe Rucoa::RangeFormattingProvider do
  describe '.call' do
    subject do
      described_class.call(
        range: range,
        source: source
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

    let(:range) do
      Rucoa::Range.from_vscode_range(
        'end' => {
          'character' => 0,
          'line' => 1
        },
        'start' => {
          'character' => 0,
          'line' => 0
        }
      )
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
        is_expected.to eq([])
      end
    end

    context 'when no offense is found in given range' do
      include_context 'when RuboCop is configured'

      it 'returns empty edits' do
        is_expected.to eq([])
      end
    end

    context 'when some offenses are found in given range' do
      include_context 'when RuboCop is configured'
      include_context 'with some offenses'

      it 'returns edits to autocorrect them' do
        is_expected.to match(
          [
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
          ]
        )
      end
    end
  end
end
