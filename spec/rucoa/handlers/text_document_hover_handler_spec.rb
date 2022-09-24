# frozen_string_literal: true

RSpec.describe Rucoa::Handlers::TextDocumentHoverHandler do
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
        'method' => 'textDocument/hover',
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
        'foo'.to_i
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
        column: 7,
        line: 1
      )
    end

    context 'when no node is found at the position' do
      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 2
        )
      end

      it 'responds with nil result' do
        subject
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

    context 'with String#to_i method call is hovered' do
      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => {
                'contents' => /\AString#to_i/,
                'range' => {
                  'end' => {
                    'character' => 10,
                    'line' => 0
                  },
                  'start' => {
                    'character' => 0,
                    'line' => 0
                  }
                }
              }
            )
          ]
        )
      end
    end

    context 'when inherited method call is hovered' do
      let(:content) do
        <<~RUBY
          module A
            class Foo
              def foo
              end
            end

            class Bar < Foo
              def bar
                foo
              end
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 9,
          line: 9
        )
      end

      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'contents' => /\AA::Foo#foo/
              )
            )
          ]
        )
      end
    end

    context 'when constant is hovered' do
      let(:content) do
        <<~RUBY
          class Foo
          end
          Foo
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 3
        )
      end

      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'contents' => "Foo\n"
              )
            )
          ]
        )
      end
    end

    context 'when resolvable constant is hovered' do
      let(:content) do
        <<~RUBY
          class A
            class Foo
            end

            class Bar < Foo
              def baz
                Bar
              end
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 6,
          line: 7
        )
      end

      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'contents' => "A::Bar\n"
              )
            )
          ]
        )
      end
    end

    context 'when non-class and non-module constant is hovered' do
      let(:content) do
        <<~RUBY
          # Returns one.
          # @return [Integer]
          A = 1

          A
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 0,
          line: 5
        )
      end

      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'contents' => "A\nReturns one."
              )
            )
          ]
        )
      end
    end

    context 'when singleton method call is hovered' do
      let(:content) do
        <<~RUBY
          class Foo
            def self.foo
            end
          end

          Foo.foo
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 7,
          line: 6
        )
      end

      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'contents' => /\AFoo\.foo/
              )
            )
          ]
        )
      end
    end

    context 'when another style of singleton method call is hovered' do
      let(:content) do
        <<~RUBY
          class A
            def foo
              B.call
            end

            class B
              class << self
                def call
                end
              end
            end
          end
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 10,
          line: 3
        )
      end

      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'contents' => /\AA::B.call/
              )
            )
          ]
        )
      end
    end

    context 'when extended method call is hovered' do
      let(:content) do
        <<~RUBY
          module A
            def foo
            end
          end

          class B
            extend A
          end

          B.foo
        RUBY
      end

      let(:position) do
        Rucoa::Position.new(
          column: 5,
          line: 10
        )
      end

      it 'responds hover' do
        subject
        expect(server.responses).to match(
          [
            hash_including(
              'id' => 1,
              'result' => hash_including(
                'contents' => /\AA#foo/
              )
            )
          ]
        )
      end
    end
  end
end
