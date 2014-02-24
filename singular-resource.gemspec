Gem::Specification.new do |s|
  s.name = "singular-resource"
  s.version = '0.0.1'
  s.licenses = ['MIT']
  s.summary = "Subset of decent_exposure, leaves the good parts and dismisses the 'magic'"
  s.description = "Extracted from decent exposure, attempts to leave the useful parts, and just use `helper_method` to expose your view models."
  s.authors = ["Máximo Mussini"]

  s.email = ["maximomussini@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir.glob("{lib}/**/*") + %w(README.md)
  s.homepage = %q{https://github.com/ElMassimo/singular-resource}

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=2.0'
  s.has_rdoc = false
  s.rdoc_options = ["--main"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport'
end
