require_relative 'lib/ymlbill/version'

Gem::Specification.new do |spec|
  spec.name        = 'ymlbill'
  spec.version     = Ymlbill::VERSION
  spec.summary     = 'A CLI tool to generate PDF invoices and quotes from YAML files.'
  spec.description = 'A CLI tool that converts YAML invoice/quote definitions into styled PDF documents using ERB and headless Chromium.'
  spec.authors     = ['David Hagege']
  spec.email       = ['david@joynetiks.com']
  spec.homepage    = 'https://github.com/pcboy/ymlbill'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.files = Dir['lib/**/*.rb', 'lib/ymlbill/templates/**/*', 'exe/*', 'README.md', 'LICENSE.txt']
  spec.bindir = 'exe'
  spec.executables = ['ymlbill']

  spec.add_dependency 'ferrum', '~> 0.15'
  spec.add_dependency 'money', '~> 7.1.1'
  spec.add_dependency 'ostruct', '~> 0.6'
  spec.add_dependency 'thor', '~> 1.5.0'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
