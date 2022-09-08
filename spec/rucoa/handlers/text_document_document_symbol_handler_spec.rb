# frozen_string_literal: true

require 'stringio'
require 'tmpdir'

RSpec.describe Rucoa::Handlers::TextDocumentDocumentSymbolHandler do
  describe '.call' do
    subject do
      described_class.call(
        request: request,
        server: server
      )
    end

    before do
      server.source_store.update(source)
    end

    let(:request) do
      {
        'id' => 1,
        'method' => 'textDocument/documentSymbol',
        'params' => {
          'textDocument' => {
            'uri' => uri
          }
        }
      }
    end

    let(:server) do
      Rucoa::Server.new(
        input: StringIO.new,
        output: StringIO.new
      )
    end

    let(:content) do
      <<~RUBY
        module Foo
          class Bar
            A = 1

            class << self
              def a
              end
            end

            def self.b
            end

            def Bar.c
            end

            attr_reader :c
            attr_reader :d, :e
            attr_writer :f
            attr_accessor :g

            def initialize
            end

            def a
            end

            def b
            end

            class Baz
              def a
              end
            end
          end
        end
      RUBY
    end

    let(:uri) do
      "file://#{file_path}"
    end

    let(:file_path) do
      'example.rb'
    end

    let(:source) do
      Rucoa::Source.new(
        content: content,
        uri: uri
      )
    end

    context 'with valid condition' do
      it 'stores source and published empty diagnostics' do
        subject
        expect(server.responses).to match(
          [
            {
              'id' => 1,
              'jsonrpc' => '2.0',
              'result' => [
                {
                  'children' => [
                    hash_including(
                      'children' => [
                        hash_including('name' => 'A'),
                        hash_including('name' => '.a'),
                        hash_including('name' => '.b'),
                        hash_including('name' => '.c'),
                        hash_including('name' => 'c'),
                        hash_including('name' => 'd'),
                        hash_including('name' => 'e'),
                        hash_including('name' => 'f'),
                        hash_including('name' => 'g'),
                        hash_including('name' => '#initialize'),
                        hash_including('name' => '#a'),
                        hash_including('name' => '#b'),
                        hash_including(
                          'children' => [
                            hash_including('name' => '#a')
                          ],
                          'name' => 'Baz'
                        )
                      ],
                      'name' => 'Bar'
                    )
                  ],
                  'kind' => 2,
                  'name' => 'Foo',
                  'range' => {
                    'end' => { 'character' => 3, 'line' => 34 },
                    'start' => { 'character' => 0, 'line' => 0 }
                  },
                  'selectionRange' => {
                    'end' => { 'character' => 10, 'line' => 0 },
                    'start' => { 'character' => 7, 'line' => 0 }
                  }
                }
              ]
            }
          ]
        )
      end
    end
  end
end
