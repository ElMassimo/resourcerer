Gem::Specification.new do |s|
  s.name = "resourcerer"
  s.version = '1.0.0'
  s.licenses = ['MIT']
  s.summary = "Dry up your controllers by defining resources"
  s.description = "Define resources to automate finding a record and assigning attributes."
  s.authors = ["Máximo Mussini"]

  s.email = ["maximomussini@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir.glob("{lib}/**/*.rb") + %w(README.md)
  s.homepage = %q{https://github.com/ElMassimo/resourcerer}

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=2.0'
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'pakiderm'
end
