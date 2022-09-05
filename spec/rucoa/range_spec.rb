# frozen_string_literal: true

RSpec.describe Rucoa::Range do
  describe '#contains?' do
    subject do
      instance.contains?(other)
    end

    context 'when the other covers the same range' do
      let(:instance) do
        described_class.new(
          Rucoa::Position.new(
            column: 0,
            line: 0
          ),
          Rucoa::Position.new(
            column: 0,
            line: 0
          )
        )
      end

      let(:other) do
        described_class.new(
          Rucoa::Position.new(
            column: 0,
            line: 0
          ),
          Rucoa::Position.new(
            column: 0,
            line: 0
          )
        )
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the other is included in self' do
      let(:instance) do
        described_class.new(
          Rucoa::Position.new(
            column: 0,
            line: 0
          ),
          Rucoa::Position.new(
            column: 0,
            line: 2
          )
        )
      end

      let(:other) do
        described_class.new(
          Rucoa::Position.new(
            column: 0,
            line: 1
          ),
          Rucoa::Position.new(
            column: 0,
            line: 1
          )
        )
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the other is excluded in self' do
      let(:instance) do
        described_class.new(
          Rucoa::Position.new(
            column: 0,
            line: 0
          ),
          Rucoa::Position.new(
            column: 0,
            line: 0
          )
        )
      end

      let(:other) do
        described_class.new(
          Rucoa::Position.new(
            column: 0,
            line: 1
          ),
          Rucoa::Position.new(
            column: 0,
            line: 1
          )
        )
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
