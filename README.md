# Rucoa

Ruby code analyzer for better editor support.

This gem has an implementation as a Language Server and provides features such as Suggestion, Completion, and Go to Definition.

## Installation

If you are in bundler environment, add to your Gemfile:

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

## Usage

This gem is intended to be called from editor extensions.

- [vscode-rucoa](https://github.com/r7kamura/vscode-rucoa)

Currently, there is only an extension for Visual Studio Code.
If there is a request, we will prepare extensions for other editors as well.
