# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::TextDocumentDefinitionHandler do
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
        'method' => 'textDocument/definition',
        'params' => {
          'position' => position.to_vscode_position,
          'textDocument' => {
            'text' => content,
            'uri' => uri
          }
        }
      }
    end

    let(:server) do
      Rucoa::Server.new
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        uri: uri
      )
    end

    let(:uri) do
      'file:///example.rb'
    end

    context 'when cursor is positioned at A#bar method call' do
      let(:content) do
        <<~RUBY
          class A
            def foo
              bar
            end

            def bar
              'bar'
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 7,
          line: 3
        )
      end

      it 'returns its A#bar definition location' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'range' => {
                  'end' => {
                    'character' => 5,
                    'line' => 7
                  },
                  'start' => {
                    'character' => 2,
                    'line' => 5
                  }
                },
                'uri' => uri
              )
            )
          ]
        )
      end
    end

    context 'when cursor is positioned at A constant reference' do
      let(:content) do
        <<~RUBY
          class A
            def foo
              A
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 5,
          line: 3
        )
      end

      it 'returns class A definition location' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'range' => {
                  'end' => {
                    'character' => 3,
                    'line' => 4
                  },
                  'start' => {
                    'character' => 0,
                    'line' => 0
                  }
                },
                'uri' => uri
              )
            )
          ]
        )
      end
    end

    context 'when cursor is positioned at A constant reference in nested module' do
      let(:content) do
        <<~RUBY
          module A
            class B
              def foo
                A
              end
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 7,
          line: 4
        )
      end

      it 'returns module A definition location' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'range' => {
                  'end' => {
                    'character' => 3,
                    'line' => 6
                  },
                  'start' => {
                    'character' => 0,
                    'line' => 0
                  }
                },
                'uri' => uri
              )
            )
          ]
        )
      end
    end

    context 'with A::B const node' do
      let(:content) do
        <<~RUBY
          module A
            class B
              def foo
                B::C
              end

              class C
              end
            end

            class C
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 10,
          line: 4
        )
      end

      it 'returns module A definition location' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'range' => {
                  'end' => {
                    'character' => 7,
                    'line' => 7
                  },
                  'start' => {
                    'character' => 4,
                    'line' => 6
                  }
                },
                'uri' => uri
              )
            )
          ]
        )
      end
    end

    context 'with inherited method' do
      let(:content) do
        <<~RUBY
          class A
            def foo
            end
          end

          class B < A
            def bar
              foo
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 7,
          line: 8
        )
      end

      it 'returns A#foo definition location' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'range' => {
                  'end' => {
                    'character' => 5,
                    'line' => 2
                  },
                  'start' => {
                    'character' => 2,
                    'line' => 1
                  }
                },
                'uri' => uri
              )
            )
          ]
        )
      end
    end
  end
end
