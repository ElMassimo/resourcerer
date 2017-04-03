require File.expand_path('../lib/resourcerer/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'resourcerer'
  s.version = Resourcerer::VERSION
  s.authors = ['Máximo Mussini']
  s.email = ['maximomussini@gmail.com']
  s.summary = 'Dry up your controllers by defining resources'
  s.description = 'Define resources to automatically find a record and assign its attributes.'
  s.homepage = 'https://github.com/ElMassimo/resourcerer'
  s.license = 'MIT'
  s.extra_rdoc_files = ['README.md']
  s.files = Dir.glob('{lib}/**/*.rb') + %w(README.md)
  s.test_files   = Dir.glob('{spec}/**/*.rb')
  s.require_path = 'lib'

  s.required_ruby_version = '~> 2.2'

  s.add_dependency 'activesupport', '>= 4.0'
  s.add_development_dependency 'activemodel'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'railties', '>= 4.0'
  s.add_development_dependency 'rspec-given', '~> 3.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
end
