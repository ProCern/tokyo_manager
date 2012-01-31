version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'tokyo_manager'
  s.version = version
  s.summary = 'A tool for managing multipl instances of TokyoTyrant set do store data in a different database each month.'
  s.description = 'A tool for managing multipl instances of TokyoTyrant set do store data in a different database each month.'

  s.required_ruby_version = '>= 1.8.7'

  s.author = 'Adam Vaughan'
  s.email = 'ajv@absolute-performance.com'
  s.homepage = 'http://www.absolute-performance.com'

  s.files = Dir['VERSION', 'README.rdoc', 'bin/*', 'lib/**/*']
  s.executables = ['tokyo-manager']
  s.require_path = 'lib'

  s.add_dependency 'ruby-tokyotyrant', '~> 0.5'
  s.add_dependency 'thor', '>= 0.11.5'
  s.add_dependency 'activesupport', '~> 3.0'
end
