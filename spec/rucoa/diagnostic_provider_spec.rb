# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Rucoa::DiagnosticProvider do
  describe '.call' do
    subject do
      described_class.call(
        source: source
      )
    end

    before do
      File.write(file_path, content)
    end

    after do
      File.delete(file_path)
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        path: file_path
      )
    end

    let(:content) do
      raise NotImplementedError
    end

    let(:file_path) do
      "#{Dir.tmpdir}/example.rb"
    end

    context 'with no offense' do
      let(:content) do
        <<~RUBY
          # frozen_string_literal: true

          'foo'
        RUBY
      end

      it 'returns expected diagnostics' do
        is_expected.to eq([])
      end
    end

    context 'with some offenses' do
      let(:content) do
        <<~RUBY
          # frozen_string_literal: true

          "foo"
        RUBY
      end

      it 'returns expected diagnostics' do
        is_expected.to match(
          [
            {
              code: 'Style/StringLiterals',
              data: {
                cop_name: 'Style/StringLiterals',
                correctable: true,
                path: file_path,
                range: a_kind_of(Hash)
              },
              message: /\APrefer single-quoted strings/,
              range: {
                start: {
                  line: 2,
                  character: 0
                },
                end: {
                  line: 2,
                  character: 5
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
