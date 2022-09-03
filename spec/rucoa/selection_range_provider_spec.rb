# frozen_string_literal: true

RSpec.describe Rucoa::SelectionRangeProvider do
  describe '.call' do
    subject do
      described_class.call(
        position: position,
        text: text
      )
    end

    let(:text) do
      raise NotImplementedError
    end

    context 'with String node' do
      let(:text) do
        <<~RUBY
          'foo'
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          line: 1,
          column: 0
        )
      end

      it 'returns expected selection ranges' do
        is_expected.to eq(
          {
            parent: {
              parent: nil,
              range: {
                end: {
                  character: 5,
                  line: 0
                },
                start: {
                  character: 0,
                  line: 0
                }
              }
            },
            range: {
              end: {
                character: 4,
                line: 0
              },
              start: {
                character: 1,
                line: 0
              }
            }
          }
        )
      end
    end

    context 'without node' do
      let(:text) do
        <<~RUBY
          'foo'
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          line: 1,
          column: 5
        )
      end

      it 'returns expected selection ranges' do
        is_expected.to be_nil
      end
    end
  end
end
