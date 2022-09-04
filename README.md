# Rucoa

[![test](https://github.com/r7kamura/rucoa/actions/workflows/test.yml/badge.svg)](https://github.com/r7kamura/rucoa/actions/workflows/test.yml)

Language server for Ruby.

## Usage

Install both rucoa gem and [vscode-rucoa](https://github.com/r7kamura/vscode-rucoa) extension, then open your Ruby project in VSCode.

To install rucoa gem, if your project is managed by bundler, add to your Gemfile:

```ruby
# Gemfile
gem 'rucoa'
```

or in Rails application, we'll recommend you to do like this:

```ruby
# Gemfile
group :development do
  gem 'rucoa', require: false
end
```

If bundler is not being used to manage dependencies, simply install the gem:

```bash
gem install rucoa
```

## Features

- Diagnostics
- Quick Fix
- Selection Ranges (experimental)

### Coming soon

- Completion
- Documentation
- Formatting
- Highlight
- Go to Definition
