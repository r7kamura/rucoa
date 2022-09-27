# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::TextDocumentDocumentHighlightHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: request,
        server: server
      )
    end

    before do
      server.source_store.update(source)
      server.definition_store.update_from(source)
    end

    let(:request) do
      {
        'id' => 1,
        'method' => 'textDocument/documentHighlight',
        'params' => {
          'position' => position.to_vscode_position,
          'textDocument' => {
            'uri' => uri
          }
        }
      }
    end

    let(:server) do
      Rucoa::Server.new(
        io_in: StringIO.new,
        io_out: StringIO.new
      )
    end

    let(:file_path) do
      'example.rb'
    end

    let(:uri) do
      "file://#{file_path}"
    end

    let(:content) do
      <<~RUBY
        class A
        end
      RUBY
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        uri: uri
      )
    end

    let(:position) do
      Rucoa::Position.new(
        column: 0,
        line: 2
      )
    end

    context 'when highlight is disabled' do
      before do
        server.configuration.disable_highlight
      end

      it 'returns an empty array' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => []
            )
          ]
        )
      end
    end

    context 'when class end node is detected' do
      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => [
                {
                  'kind' => 1,
                  'range' => {
                    'end' => {
                      'character' => 5,
                      'line' => 0
                    },
                    'start' => {
                      'character' => 0,
                      'line' => 0
                    }
                  }
                },
                {
                  'kind' => 1,
                  'range' => {
                    'end' => {
                      'character' => 3,
                      'line' => 1
                    },
                    'start' => {
                      'character' => 0,
                      'line' => 1
                    }
                  }
                }
              ]
            )
          ]
        )
      end
    end

    context 'when module keyword node is detected' do
      let(:content) do
        <<~RUBY
          module A
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(2) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when def node is detected' do
      let(:content) do
        <<~RUBY
          def foo
            1
          rescue A
            2
          rescue
            3
          else
            4
          ensure
            5
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(6) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when def-rescue node is detected' do
      let(:content) do
        <<~RUBY
          def foo
            1
          rescue A
            2
          rescue
            3
          else
            4
          ensure
            5
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 3
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(6) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when def-else node is detected' do
      let(:content) do
        <<~RUBY
          def foo
            1
          rescue A
            2
          rescue
            3
          else
            4
          ensure
            5
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 7
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(6) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when begin node is detected' do
      let(:content) do
        <<~RUBY
          begin
            1
          rescue A
            2
          rescue
            3
          else
            4
          ensure
            5
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(6) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when send node is detected' do
      let(:content) do
        <<~RUBY
          foo do
            1
          rescue A
            2
          rescue
            3
          else
            4
          ensure
            5
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(6) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when block node is detected' do
      let(:content) do
        <<~RUBY
          foo do
            1
          rescue A
            2
          rescue
            3
          else
            4
          ensure
            5
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 4
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(6) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when case node is detected' do
      let(:content) do
        <<~RUBY
          case foo
          when A
            1
          when B
            2
          else
            3
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(5) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when when node is detected' do
      let(:content) do
        <<~RUBY
          case foo
          when A
            1
          when B
            2
          else
            3
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 2
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(5) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when when-else node is detected' do
      let(:content) do
        <<~RUBY
          case foo
          when A
            1
          when B
            2
          else
            3
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 6
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(5) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when if node is detected' do
      let(:content) do
        <<~RUBY
          if foo
            1
          elsif bar
            2
          else
            3
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(4) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when elsif node is detected' do
      let(:content) do
        <<~RUBY
          if foo
            1
          elsif bar
            2
          else
            3
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 3
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(4) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when unless node is detected' do
      let(:content) do
        <<~RUBY
          unless foo
            1
          else
            2
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(3) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when while node is detected' do
      let(:content) do
        <<~RUBY
          while foo
            1
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(2) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when until node is detected' do
      let(:content) do
        <<~RUBY
          until foo
            1
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(2) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when for node is detected' do
      let(:content) do
        <<~RUBY
          for foo in bar
            1
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(3) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end

    context 'when for-in node is detected' do
      let(:content) do
        <<~RUBY
          for foo in bar
            1
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 8,
          line: 1
        )
      end

      it 'returns keyword ranges' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => Array.new(3) do
                a_kind_of(Hash)
              end
            )
          ]
        )
      end
    end
  end
end
