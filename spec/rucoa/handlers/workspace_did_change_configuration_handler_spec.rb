# frozen_string_literal: true

require 'stringio'

RSpec.describe Rucoa::Handlers::WorkspaceDidChangeConfigurationHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: {
          'id' => 1,
          'method' => 'workspace/didChangeConfiguration',
          'params' => {}
        },
        server: server
      )
    end

    let(:server) do
      Rucoa::Server.new(
        input: StringIO.new,
        output: StringIO.new
      )
    end

    context 'with valid condition' do
      it 'requests workspace configuration' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 0,
              'method' => 'workspace/configuration',
              'params' => {
                'items' => [
                  {
                    'section' => 'rucoa'
                  }
                ]
              }
            )
          ]
        )
      end
    end
  end
end
