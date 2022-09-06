# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Handlers::InitializeHandler do
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
        'method' => 'initialize',
        'params' => {}
      }
    end

    let(:server) do
      Rucoa::Server.new(
        input: input,
        output: output
      )
    end

    let(:input) do
      StringIO.new
    end

    let(:output) do
      StringIO.new
    end

    context 'with valid condition' do
      it 'responds server capabilities' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => {
                'capabilities' => hash_including(
                  'codeActionProvider' => true
                )
              }
            )
          ]
        )
      end
    end
  end
end
