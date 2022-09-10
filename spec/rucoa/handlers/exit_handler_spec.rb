# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Handlers::ExitHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: request,
        server: server
      )
    end

    let(:request) do
      {
        'id' => 1,
        'method' => 'exit',
        'params' => nil
      }
    end

    let(:server) do
      Rucoa::Server.new(
        input: StringIO.new,
        output: StringIO.new
      )
    end

    context 'with valid condition' do
      before do
        allow(server).to receive(:exit)
      end

      it 'exits with status code 0' do
        subject
        expect(server).to have_received(:exit).with(0)
      end
    end
  end
end
