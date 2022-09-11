# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::WorkspaceDidChangeConfigurationHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: {
          'id' => 1,
          'method' => 'workspace/didChangeConfiguration',
          'params' => {
            'settings' => {
              'feature' => {
                'diagnostics' => {
                  'enable' => false
                }
              }
            }
          }
        },
        server: server
      )
    end

    let(:server) do
      Rucoa::Server.new
    end

    context 'with valid condition' do
      it 'updates settings' do
        expect { subject }.to change { server.configuration.enables_diagnostics? }.from(true).to(false)
      end
    end
  end
end
