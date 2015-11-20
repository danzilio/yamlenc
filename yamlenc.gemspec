lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'enc/version'

Gem::Specification.new do |s|
  s.name = 'yamlenc'
  s.version = Enc::VERSION

  s.homepage = 'https://github.com/danzilio/yamlenc'
  s.summary = 'A Puppet ENC that pulls from YAML'
  s.description = s.summary
  s.license = 'MIT'

  s.executables = ['enc']

  s.files = Dir['README.md', 'lib/**/*', 'bin/**/*']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>=3.0.0'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'cucumber'

  s.authors = ['David Danzilio']
  s.email = 'ddanzilio@constantcontact.com'

  s.test_files = Dir.glob('spec/**/*')
end
