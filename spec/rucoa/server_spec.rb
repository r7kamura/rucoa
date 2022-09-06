# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Server do
  describe '#start' do
    subject do
      instance.start
    end

    let(:instance) do
      described_class.new(
        input: input,
        output: StringIO.new
      )
    end

    let(:input) do
      StringIO.new(raw_input)
    end

    context 'when responsible request is sent' do
      let(:raw_input) do
        Rucoa::MessageWriter.pack(
          id: 1,
          method: 'initialize',
          params: {}
        )
      end

      it 'sends response' do
        subject
        expect(instance.responses).to match(
          [
            hash_including(
              'id' => 1
            )
          ]
        )
      end
    end

    context 'when unknown request is sent' do
      let(:raw_input) do
        Rucoa::MessageWriter.pack(
          id: 1,
          method: 'unknown',
          params: {}
        )
      end

      it 'does nothing' do
        subject
        expect(instance.responses).to be_empty
      end
    end
  end
end
