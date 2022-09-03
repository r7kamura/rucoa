# frozen_string_literal: true

require_relative 'lib/rucoa/version'

Gem::Specification.new do |spec|
  spec.name = 'rucoa'
  spec.version = Rucoa::VERSION
  spec.authors = ['Ryo Nakamura']
  spec.email = ['r7kamura@gmail.com']

  spec.summary = 'Language server for Ruby.'
  spec.homepage = 'https://github.com/r7kamura/rucoa'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'parser'
end
