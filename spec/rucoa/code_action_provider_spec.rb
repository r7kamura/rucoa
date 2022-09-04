# frozen_string_literal: true

RSpec.describe Rucoa::CodeActionProvider do
  describe '.call' do
    subject do
      described_class.call(
        diagnostics: diagnostics
      )
    end

    context 'with some diagnostics' do
      let(:diagnostics) do
        [
          {
            'code' => 'Style/StringLiterals',
            'data' => {
              'cop_name' => 'Style/StringLiterals',
              'edits' => [
                {
                  'newText' => "'foo'",
                  'range' => range
                }
              ],
              'path' => file_path,
              'range' => range,
              'uri' => uri
            },
            'message' => 'Prefer single-quoted strings...',
            'range' => range,
            'severity' => 3,
            'source' => 'RuboCop'
          }
        ]
      end

      let(:file_path) do
        'example.rb'
      end

      let(:uri) do
        "file://#{file_path}"
      end

      let(:range) do
        {
          'end' => {
            'character' => 5,
            'line' => 2
          },
          'start' => {
            'character' => 0,
            'line' => 2
          }
        }
      end

      it 'returns some code actions' do
        is_expected.to match(
          [
            {
              diagnostics: diagnostics,
              edit: {
                documentChanges: [
                  {
                    edits: [
                      {
                        'newText' => "'foo'",
                        'range' => range
                      }
                    ],
                    textDocument: {
                      uri: uri,
                      version: nil
                    }
                  }
                ]
              },
              isPreferred: true,
              kind: 'quickfix',
              title: 'Autocorrect Style/StringLiterals'
            }
          ]
        )
      end
    end
  end
end
