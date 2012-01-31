# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tokyo_manager/version', __FILE__)

Gem::Specification.new do |gem|
  gem.platform = Gem::Platform::RUBY
  gem.name = 'tokyo_manager'
  gem.version = TokyoManager::VERSION
  gem.summary = 'A tool for managing multipl instances of TokyoTyrant set do store data in a different database each month.'
  gem.description = 'A tool for managing multipl instances of TokyoTyrant set do store data in a different database each month.'

  gem.required_ruby_version = '>= 1.8.7'

  gem.author = 'Adam Vaughan'
  gem.email = 'ajv@absolute-performance.com'
  gem.homepage = 'http://www.absolute-performance.com'

  gem.files = Dir['VERSION', 'README.rdoc', 'bin/*', 'lib/**/*']
  gem.executables = ['tokyo-manager']
  gem.require_path = 'lib'

  gem.add_dependency 'ruby-tokyotyrant', '~> 0.5'
  gem.add_dependency 'thor', '>= 0.11.5'
  gem.add_dependency 'activesupport', '~> 3.0'
end
