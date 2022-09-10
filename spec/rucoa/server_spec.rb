# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Server do
  describe '#start' do
    subject do
      instance.start
    end

    let(:instance) do
      described_class.new(
        io_in: io_input,
        io_log: io_log
      )
    end

    let(:io_input) do
      StringIO.new(raw_input)
    end

    let(:io_log) do
      StringIO.new
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
        expect(io_log.string).to eq('')
      end
    end

    context 'when debug mode is enabled' do
      before do
        instance.configuration.enable_debug
      end

      let(:raw_input) do
        Rucoa::MessageWriter.pack(
          id: 1,
          method: 'initialize',
          params: {}
        )
      end

      it 'writes debug log' do
        subject
        expect(io_log.string).to match(':kind=>:read')
        expect(io_log.string).to match(':kind=>:write')
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
