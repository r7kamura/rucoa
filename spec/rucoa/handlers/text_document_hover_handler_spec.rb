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
      server.definition_store.update_definitions_defined_in(
        source.path,
        definitions: source.definitions
      )
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

    context 'with valid condition' do
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

    context 'when method is defined in super class in YARD' do
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
  end
end
