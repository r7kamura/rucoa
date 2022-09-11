# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::ShutdownHandler do
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
        'method' => 'shutdown',
        'params' => nil
      }
    end

    let(:server) do
      Rucoa::Server.new
    end

    context 'with valid condition' do
      it 'responds null result and change shutting status to true' do
        expect { subject }.to change(server, :shutting_down).from(false).to(true)
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => nil
            )
          ]
        )
      end
    end
  end
end
